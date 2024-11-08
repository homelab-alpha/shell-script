// Required Dependencies
const NotificationProvider = require('./notification-provider')
const axios = require('axios')
const { setSettings, setting } = require('../util-server')
const { getMonitorRelativeURL, UP, log } = require('../../src/util')
const dayjs = require('dayjs')
const utc = require('dayjs/plugin/utc')
const timezone = require('dayjs/plugin/timezone')

// Extend dayjs with UTC and timezone plugins for proper time formatting
dayjs.extend(utc)
dayjs.extend(timezone)

class Slack extends NotificationProvider {
  name = 'slack'

  /**
   * Sends a Slack notification with optional detailed blocks if heartbeat data is provided.
   * The message can include a channel notification tag if specified.
   *
   * @param {object} notification - Slack notification configuration (e.g., webhook URL, channel, etc.).
   * @param {string} message - The content to be sent in the Slack notification.
   * @param {object|null} monitor - The monitor object containing monitor details (optional).
   * @param {object|null} heartbeat - Heartbeat data (optional) to be included in the notification.
   *
   * @returns {Promise<string>} - A success message indicating the notification was sent.
   */
  async send (notification = {}, message, monitor = null, heartbeat = null) {
    const successMessage = 'Sent Successfully.'

    // Validate the provided Slack notification configuration
    try {
      this.validateNotificationConfig(notification)
    } catch (error) {
      log.error('Slack notification configuration error', {
        error: error.message
      })
      throw new Error('Notification configuration is incorrect.')
    }

    // Append the Slack channel notification tag if configured
    if (notification.slackchannelnotify) {
      message += ' <!channel>'
    }

    try {
      // Retrieve the base URL from settings for constructing monitor links
      const baseURL = await setting('primaryBaseURL')

      // Construct the payload for the Slack notification, including heartbeat if available
      const data = this.createSlackData(
        notification,
        message,
        monitor,
        heartbeat,
        baseURL
      )

      // Process any deprecated Slack button URL if configured
      if (notification.slackbutton) {
        await Slack.deprecateURL(notification.slackbutton)
      }

      // Send the notification data to the configured Slack webhook URL
      const response = await axios.post(notification.slackwebhookURL, data)

      // Log the successful notification send
      log.info('Slack notification sent successfully', {
        response: response.data
      })

      return successMessage
    } catch (error) {
      // Log detailed error information in case of failure
      log.error('Slack notification failed', {
        message: error.message,
        stack: error.stack,
        response: error.response?.data || 'No response data'
      })

      // Handle errors by throwing a generalized Axios error
      this.throwGeneralAxiosError(error)
    }
  }

  /**
   * Validates the configuration object for Slack notifications to ensure all required fields are present.
   * Sets a default icon if not provided.
   *
   * @param {object} notification - The Slack notification configuration object.
   * @throws {Error} - Throws an error if any required fields are missing or invalid.
   */
  validateNotificationConfig (notification) {
    const requiredFields = [
      {
        field: 'slackwebhookURL',
        message: 'Slack webhook URL is required for notifications.'
      },
      {
        field: 'slackchannel',
        message: 'Slack channel is required for notifications.'
      },
      {
        field: 'slackusername',
        message: 'Slack username is required for notifications.'
      }
    ]

    // Ensure all required fields are present in the configuration
    requiredFields.forEach(({ field, message }) => {
      if (!notification[field]) {
        throw new Error(message)
      }
    })

    // Set default icon if none is specified
    if (!notification.slackiconemo) {
      notification.slackiconemo = ':robot_face:' // Default emoji icon
    }
  }

  /**
   * Creates the payload for the Slack message, optionally including rich content with heartbeat data.
   * Constructs a simple message or a detailed one based on configuration.
   *
   * @param {object} notification - The configuration object for Slack notifications.
   * @param {string} message - The main content of the notification message.
   * @param {object|null} monitor - Monitor object containing monitor details (optional).
   * @param {object|null} heartbeat - Heartbeat data for the monitor (optional).
   * @param {string} baseURL - The base URL of Uptime Kuma used to create monitor-specific links.
   *
   * @returns {object} - The payload formatted for Slack notification.
   */
  createSlackData (notification, message, monitor, heartbeat, baseURL) {
    const title = 'Uptime Kuma Alert' // Title of the notification
    const status = heartbeat.status === UP ? '✅' : '🔴' // Set status icon based on heartbeat status
    const colorBased = heartbeat.status === UP ? '#2eb886' : '#e01e5a' // Set color based on status

    // Basic structure for Slack message data
    const data = {
      text: `${monitor.name} ${status}`, // Slack preview: Shows monitor name followed by its current status (UP or DOWN)
      channel: notification.slackchannel,
      username: notification.slackusername || 'Uptime Kuma (bot)', // Default username if not provided
      icon_emoji: notification.slackiconemo || ':robot_face:', // Default emoji if not provided
      attachments: []
    }

    // If heartbeat data is present and rich message is enabled, create a detailed message
    if (heartbeat && notification.slackrichmessage) {
      data.attachments.push({
        color: colorBased, // Set color based on status
        blocks: this.buildBlocks(baseURL, monitor, heartbeat, title, message) // Create the blocks for rich content
      })
    } else {
      // Fallback to a simple text message if heartbeat is not available
      data.text = `${title}\n${message}`
    }

    return data
  }

  /**
   * Builds action buttons for the Slack message to allow user interactions with the monitor.
   * Creates buttons with links to Uptime Kuma monitor and monitor address if available.
   *
   * @param {string} baseURL - The base URL of Uptime Kuma.
   * @param {object} monitor - Monitor object containing details (e.g., ID and address).
   *
   * @returns {Array} - An array of button objects to be included in the Slack message.
   */
  buildActions (baseURL, monitor) {
    const actions = []
    if (baseURL) {
      actions.push({
        type: 'button',
        text: { type: 'plain_text', text: 'Visit Uptime Kuma' },
        value: 'Uptime-Kuma',
        url: `${baseURL}${getMonitorRelativeURL(monitor.id)}`
      })
    }

    // Add a button for monitor address if it's a valid URL and doesn't end with reserved ports
    const address = this.extractAddress(monitor)
    if (address) {
      try {
        const validURL = new URL(address)

        // Exclude URLs ending with ports 53 or 853 (commonly used for DNS or DoH)
        if (!validURL.href.endsWith(':53') && !validURL.href.endsWith(':853')) {
          actions.push({
            type: 'button',
            text: { type: 'plain_text', text: `Visit ${monitor.name}` },
            value: 'Site',
            url: validURL.href
          })
        }
      } catch (e) {
        log.debug('slack', 'Invalid URL format: \'' + address + '\'') // Log invalid address format
      }
    }

    return actions
  }

  /**
   * Constructs the Slack message blocks including the header, monitor details, and actions.
   * Adds monitor status, timezone, and local time details to the message.
   *
   * @param {string} baseURL - The base URL of Uptime Kuma.
   * @param {object} monitor - The monitor object containing details.
   * @param {object} heartbeat - Heartbeat data object.
   * @param {string} title - The title of the message.
   * @param {string} body - The content of the message body.
   *
   * @returns {Array<object>} - An array of blocks to be included in the Slack message.
   */
  buildBlocks (baseURL, monitor, heartbeat, title, body) {
    const blocks = []

    // Header block with title
    blocks.push({
      type: 'header',
      text: { type: 'plain_text', text: title }
    })

    // Format the status and clean the message content
    const status = heartbeat.status === UP ? 'UP' : 'DOWN'
    const cleanedMsg = body.replace(/\[.*?\]\s*\[.*?\]\s*/, '').trim() // Clean message by removing unwanted parts
    const localTime = this.formatTime(heartbeat.localDateTime) // Format local time for display

    // Section block with monitor details
    const details = [
      { label: 'Monitor', value: monitor.name },
      { label: 'Status', value: status },
      { label: 'Details', value: cleanedMsg },
      { label: 'Timezone', value: heartbeat.timezone },
      { label: 'Local Time', value: localTime }
    ]

    blocks.push({
      type: 'section',
      fields: details.map(({ label, value }) => ({
        type: 'mrkdwn',
        text: `*${label}*:\n${value}`
      }))
    })

    // Add action buttons if available
    const actions = this.buildActions(baseURL, monitor)
    if (actions.length) {
      blocks.push({ type: 'actions', elements: actions })
    }

    return blocks
  }

  /**
   * Formats a UTC time string into a readable local time string.
   *
   * @param {string} utcTime - The UTC time to be formatted.
   * @returns {string} - The formatted local time string.
   */
  formatTime (utcTime) {
    return dayjs
      .utc(utcTime)
      .utcOffset('+00:00')
      .format('dddd MMM DD, YYYY HH:mm:ss') // Format UTC to local time string
  }

  /**
   * Handles deprecated Slack button URL and migrates it to the primary base URL if needed.
   *
   * @param {string} url - The deprecated URL to migrate.
   */
  static async deprecateURL (url) {
    const currentPrimaryBaseURL = await setting('primaryBaseURL')
    if (!currentPrimaryBaseURL) {
      console.log('Migrating URL to the primary base URL')
      await setSettings('general', {
        primaryBaseURL: url
      })
    } else {
      console.log('Already set, no need to migrate the primary base URL')
    }
  }
}

module.exports = Slack
