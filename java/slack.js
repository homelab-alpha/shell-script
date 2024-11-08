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
    const localDate = this.formatDate(heartbeat.localDateTime, heartbeat.timezone) // Format the date for display
    const localTime = this.formatTime(heartbeat.localDateTime, heartbeat.timezone) // Format the time for display

    // Get the country based on the timezone
    const country = this.getCountryFromTimezone(heartbeat.timezone)

    // Create the fields with the proper labels and values
    const fields = [
      { label: 'Monitor', value: monitor.name },
      { label: 'Status', value: status },
      { label: 'Country', value: country },
      { label: 'Details', value: `\n  ${cleanedMsg}` },
      { label: 'Date', value: localDate },
      { label: 'Time', value: localTime }
    ]

    // Push the section block with formatted fields
    blocks.push({
      type: 'section',
      fields: fields.map(({ label, value }) => ({
        type: 'mrkdwn',
        // Bold the label and keep the value on the same line
        text: `*${label}*: ${value}`
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
   * Formats a UTC time string into a readable local date string.
   *
   * @param {string} utcTime - The UTC time to be formatted.
   * @param {string} timezone - The timezone to convert to.
   * @returns {string} - The formatted local date string.
   */
  formatDate (utcTime, timezone) {
    return dayjs
      .utc(utcTime)
      .utcOffset(timezone)
      .format('dddd MMM DD YYYY')
  }

  /**
   * Formats a UTC time string into a readable local time string.
   *
   * @param {string} utcTime - The UTC time to be formatted.
   * @param {string} timezone - The timezone to convert to.
   * @returns {string} - The formatted local time string.
   */
  formatTime (utcTime, timezone) {
    return dayjs
      .utc(utcTime)
      .utcOffset(timezone)
      .format('HH:mm:ss')
  }

  /**
   * Converts a timezone string to a country name.
   *
   * @param {string} timezone - The timezone string (e.g., "Europe/Amsterdam").
   * @returns {string} - The country name corresponding to the timezone.
   */
  getCountryFromTimezone (timezone) {
    const timezoneToCountry = {
      // Europe
      'Europe/Amsterdam': 'Netherlands',
      'Europe/Andorra': 'Andorra',
      'Europe/Belgrade': 'Serbia',
      'Europe/Berlin': 'Germany',
      'Europe/Brussels': 'Belgium',
      'Europe/Bucharest': 'Romania',
      'Europe/Budapest': 'Hungary',
      'Europe/Chisinau': 'Moldova',
      'Europe/Copenhagen': 'Denmark',
      'Europe/Dublin': 'Ireland',
      'Europe/Helsinki': 'Finland',
      'Europe/Istanbul': 'Turkey',
      'Europe/Kiev': 'Ukraine',
      'Europe/Lisbon': 'Portugal',
      'Europe/London': 'United Kingdom',
      'Europe/Luxembourg': 'Luxembourg',
      'Europe/Madrid': 'Spain',
      'Europe/Minsk': 'Belarus',
      'Europe/Monaco': 'Monaco',
      'Europe/Moscow': 'Russia',
      'Europe/Oslo': 'Norway',
      'Europe/Paris': 'France',
      'Europe/Prague': 'Czech Republic',
      'Europe/Riga': 'Latvia',
      'Europe/Rome': 'Italy',
      'Europe/Samara': 'Russia',
      'Europe/Sofia': 'Bulgaria',
      'Europe/Stockholm': 'Sweden',
      'Europe/Tallinn': 'Estonia',
      'Europe/Tirane': 'Albania',
      'Europe/Vaduz': 'Liechtenstein',
      'Europe/Vienna': 'Austria',
      'Europe/Vilnius': 'Lithuania',
      'Europe/Zurich': 'Switzerland',

      // Americas
      'America/Argentina/Buenos_Aires': 'Argentina',
      'America/Asuncion': 'Paraguay',
      'America/Bahia': 'Brazil',
      'America/Barbados': 'Barbados',
      'America/Belize': 'Belize',
      'America/Chicago': 'United States',
      'America/Colombia': 'Colombia',
      'America/Curacao': 'Curacao',
      'America/Denver': 'United States',
      'America/Detroit': 'United States',
      'America/Guatemala': 'Guatemala',
      'America/Guayaquil': 'Ecuador',
      'America/Houston': 'United States',
      'America/Indianapolis': 'United States',
      'America/Lima': 'Peru',
      'America/Los_Angeles': 'United States',
      'America/Mexico_City': 'Mexico',
      'America/New_York': 'United States',
      'America/Panama': 'Panama',
      'America/Port_of_Spain': 'Trinidad and Tobago',
      'America/Regina': 'Canada',
      'America/Santiago': 'Chile',
      'America/Sao_Paulo': 'Brazil',
      'America/Toronto': 'Canada',
      'America/Vancouver': 'Canada',
      'America/Winnipeg': 'Canada',

      // Asia
      'Asia/Amman': 'Jordan',
      'Asia/Baghdad': 'Iraq',
      'Asia/Bahrain': 'Bahrain',
      'Asia/Bangkok': 'Thailand',
      'Asia/Beirut': 'Lebanon',
      'Asia/Dhaka': 'Bangladesh',
      'Asia/Dubai': 'United Arab Emirates',
      'Asia/Hong_Kong': 'Hong Kong',
      'Asia/Irkutsk': 'Russia',
      'Asia/Jakarta': 'Indonesia',
      'Asia/Kolkata': 'India',
      'Asia/Kuala_Lumpur': 'Malaysia',
      'Asia/Kuwait': 'Kuwait',
      'Asia/Makassar': 'Indonesia',
      'Asia/Manila': 'Philippines',
      'Asia/Muscat': 'Oman',
      'Asia/Novosibirsk': 'Russia',
      'Asia/Seoul': 'South Korea',
      'Asia/Singapore': 'Singapore',
      'Asia/Taipei': 'Taiwan',
      'Asia/Tashkent': 'Uzbekistan',
      'Asia/Tokyo': 'Japan',
      'Asia/Ulaanbaatar': 'Mongolia',
      'Asia/Yangon': 'Myanmar',

      // Australia
      'Australia/Adelaide': 'Australia',
      'Australia/Brisbane': 'Australia',
      'Australia/Darwin': 'Australia',
      'Australia/Hobart': 'Australia',
      'Australia/Melbourne': 'Australia',
      'Australia/Sydney': 'Australia',

      // Africa
      'Africa/Addis_Ababa': 'Ethiopia',
      'Africa/Cairo': 'Egypt',
      'Africa/Casablanca': 'Morocco',
      'Africa/Harare': 'Zimbabwe',
      'Africa/Johannesburg': 'South Africa',
      'Africa/Khartoum': 'Sudan',
      'Africa/Lagos': 'Nigeria',
      'Africa/Nairobi': 'Kenya',
      'Africa/Tripoli': 'Libya',

      // Middle East
      'Asia/Tehran': 'Iran',
      'Asia/Qatar': 'Qatar',
      'Asia/Jerusalem': 'Israel',
      'Asia/Riyadh': 'Saudi Arabia',

      // Pacific
      'Pacific/Auckland': 'New Zealand',
      'Pacific/Fiji': 'Fiji',
      'Pacific/Guam': 'Guam',
      'Pacific/Honolulu': 'United States',
      'Pacific/Pago_Pago': 'American Samoa',
      'Pacific/Port_Moresby': 'Papua New Guinea',
      'Pacific/Suva': 'Fiji',
      'Pacific/Tarawa': 'Kiribati',
      'Pacific/Wellington': 'New Zealand',

      // Other regions
      'Antarctica/Palmer': 'Antarctica',
      'Antarctica/Vostok': 'Antarctica',
      'Indian/Chagos': 'Chagos Archipelago',
      'Indian/Mauritius': 'Mauritius',
      'Indian/Reunion': 'Réunion',
      'Indian/Christmas': 'Christmas Island',
      'Indian/Kerguelen': 'French Southern and Antarctic Lands',
      'Indian/Maldives': 'Maldives',
      'Indian/Seychelles': 'Seychelles'
    }

    return timezoneToCountry[timezone] || 'Unknown'
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
