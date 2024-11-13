// Required Dependencies
const NotificationProvider = require("./notification-provider");
const axios = require("axios");
const { setSettings, setting } = require("../util-server");
const { getMonitorRelativeURL, UP } = require("../../src/util");
const dayjs = require("dayjs");
const utc = require("dayjs/plugin/utc");
const timezone = require("dayjs/plugin/timezone");

// Extend dayjs with UTC and timezone plugins for proper time formatting
dayjs.extend(utc);
dayjs.extend(timezone);

// Global object to enable or disable specific log levels
const logLevelsEnabled = {
  debug: false, // Set to true to enable debug logs. Default is false.
  info: true, // Set to false to disable info logs. Default is true.
  warn: true, // Set to false to disable warning logs. Default is true.
  error: true, // Set to false to disable error logs. Default is true.
};

// Function to get the color for the log level
// Returns the corresponding color code based on the log level
function getLogLevelColor(logLevel) {
  const colors = {
    DEBUG: "\x1b[35m", // Purple
    INFO: "\x1b[36m", // Cyan
    WARN: "\x1b[33m", // Yellow
    ERROR: "\x1b[31m", // Red
  };
  // Return the color for the given log level or default to white if unknown
  return colors[logLevel.toUpperCase()] || "\x1b[37m"; // Default to white
}

// Function to generate a complete log message for debug level
// Only logs if the 'debug' level is enabled in logLevelsEnabled
function completeLogDebug(message, additionalInfo = null) {
  if (logLevelsEnabled.debug) {
    logMessage("DEBUG", message, additionalInfo);
  }
}

// Function to generate a complete log message for info level
// Only logs if the 'info' level is enabled in logLevelsEnabled
function completeLogInfo(message, additionalInfo = null) {
  if (logLevelsEnabled.info) {
    logMessage("INFO", message, additionalInfo);
  }
}

// Function to generate a complete log message for warn level
// Only logs if the 'warn' level is enabled in logLevelsEnabled
function completeLogWarn(message, additionalInfo = null) {
  if (logLevelsEnabled.warn) {
    logMessage("WARN", message, additionalInfo);
  }
}

// Function to generate a complete log message for error level
// Only logs if the 'error' level is enabled in logLevelsEnabled
function completeLogError(message, additionalInfo = null) {
  if (logLevelsEnabled.error) {
    logMessage("ERROR", message, additionalInfo);
  }
}

// Generic function to generate a log message
// Logs a message with timestamp, script name, and log level
function logMessage(logLevel, message, additionalInfo = null) {
  // Get the current time in a readable format with timezone offset
  const timestamp = dayjs()
    .tz("Europe/Amsterdam") // Adjust for Amsterdam timezone
    .format("YYYY-MM-DDTHH:mm:ssZ"); // Format: YYYY-MM-DDTHH:mm:ss+/-offset

  // Get the script name (hardcoded)
  const scriptName = "slack.js";

  // Define color codes for different parts of the log message
  const colors = {
    timestamp: "\x1b[36m", // Cyan
    scriptName: "\x1b[38;5;13m", // Bright Purple
    reset: "\x1b[0m", // Reset color to default
    white: "\x1b[37m", // White
  };

  // Build the log message with colors
  let logMessage = `${colors.timestamp}${timestamp}${colors.reset} `;
  logMessage += `${colors.white}[${colors.scriptName}${scriptName}${colors.white}]${colors.reset} `;
  logMessage += `${getLogLevelColor(logLevel)}${logLevel}:${
    colors.reset
  } ${message}`;

  // Add additional information if provided
  if (additionalInfo) {
    logMessage += ` | Additional Info: ${JSON.stringify(
      additionalInfo,
      null,
      2
    )}`;
  }

  // Log the final message to the console
  console.log(logMessage);
}

class Slack extends NotificationProvider {
  name = "slack";

  /**
   * Sends a Slack notification with optional detailed blocks if heartbeat data is provided.
   * The message can include a channel notification tag if configured in the notification settings.
   *
   * @param {object} notification - Slack notification configuration, including webhook URL, channel, and optional settings.
   * @param {string} message - The content to be sent in the Slack notification.
   * @param {object|null} monitor - The monitor object containing monitor details (optional).
   * @param {object|null} heartbeat - Heartbeat data to be included in the notification (optional).
   *
   * @returns {Promise<string>} - A success message indicating the notification was sent successfully.
   */
  async send(notification = {}, message, monitor = null, heartbeat = null) {
    const successMessage = "Sent Successfully.";

    // Validate the provided Slack notification configuration
    try {
      this.validateNotificationConfig(notification);
    } catch (error) {
      // Log error if configuration is invalid and rethrow with a custom error message
      completeLogError(`Slack notification configuration error`, {
        error: error.message,
        notification,
      });
      throw new Error("Notification configuration is incorrect.");
    }

    // Append the Slack channel notification tag if configured
    if (notification.slackchannelnotify) {
      message += " <!channel>"; // Adds a Slack channel notification tag to the message
      completeLogInfo(`Channel notification tag appended to message`, {
        slackchannelnotify: notification.slackchannelnotify,
      });
    }

    try {
      // Retrieve the base URL from settings for constructing monitor links
      const baseURL = await setting("primaryBaseURL");
      completeLogDebug(`Retrieved base URL for notification`, {
        baseURL,
      });

      // Construct the payload for the Slack notification, including heartbeat data if available
      const data = this.createSlackData(
        notification,
        message,
        monitor,
        heartbeat,
        baseURL
      );
      completeLogDebug(`Constructed Slack notification data`, {
        data,
      });

      // Process any deprecated Slack button URL if specified in notification settings
      if (notification.slackbutton) {
        await Slack.deprecateURL(notification.slackbutton); // Handle deprecated URL
        completeLogWarn(`Deprecated Slack button URL processed`, {
          slackbutton: notification.slackbutton,
        });
      }

      // Send the notification to the configured Slack webhook URL using Axios
      const response = await axios.post(notification.slackwebhookURL, data);
      completeLogInfo(`Slack notification sent successfully`, {
        response: response.data,
      });

      return successMessage; // Return success message after notification is sent
    } catch (error) {
      // Log detailed error information if the Slack notification fails
      completeLogError(`Slack notification failed`, {
        message: error.message,
        stack: error.stack,
        response: error.response?.data || "No response data",
        notification,
        data: {
          message,
          monitor,
          heartbeat,
        },
      });

      // Handle errors by throwing a generalized Axios error
      this.throwGeneralAxiosError(error);
    }
  }

  /**
   * Validates the configuration object for Slack notifications to ensure all required fields are present.
   * If any required fields are missing, an error is thrown. If no custom icon is provided, a default icon is set.
   *
   * @param {object} notification - The Slack notification configuration object.
   *
   * @throws {Error} - Throws an error if any required fields are missing or invalid.
   */
  validateNotificationConfig(notification) {
    const requiredFields = [
      {
        field: "slackwebhookURL",
        message: "Slack webhook URL is required for notifications.",
      },
      {
        field: "slackchannel",
        message: "Slack channel is required for notifications.",
      },
      {
        field: "slackusername",
        message: "Slack username is required for notifications.",
      },
    ];

    // Log the start of the validation process
    completeLogDebug(
      `Starting validation of Slack notification configuration`,
      {
        notification,
      }
    );

    // Ensure all required fields are present in the configuration
    requiredFields.forEach(({ field, message }) => {
      if (!notification[field]) {
        // Log error if any required field is missing
        completeLogError(
          `Missing required field in Slack notification configuration`,
          {
            field,
            message,
            notification,
          }
        );
        throw new Error(message); // Throw error with appropriate message
      }
    });

    // Log success when all required fields are present
    completeLogDebug(
      `All required fields are present in Slack notification configuration`,
      {
        requiredFields: requiredFields.map((field) => field.field),
      }
    );

    // Set a default Slack icon if none is provided
    if (!notification.slackiconemo) {
      notification.slackiconemo = ":robot_face:"; // Set default emoji icon
      completeLogDebug(`Default Slack icon emoji set`, {
        icon: notification.slackiconemo,
      });
    } else {
      completeLogDebug(`Custom Slack icon emoji provided`, {
        icon: notification.slackiconemo,
      });
    }
  }

  /**
   * Creates the payload for the Slack message, optionally including rich content with heartbeat data.
   * Constructs a simple text message or a detailed rich message based on the configuration and heartbeat data.
   *
   * @param {object} notification - The configuration object for Slack notifications.
   * @param {string} message - The main content of the notification message.
   * @param {object|null} monitor - The monitor object containing details (optional).
   * @param {object|null} heartbeat - Heartbeat data for the monitor (optional).
   * @param {string} baseURL - The base URL of Uptime Kuma used to create monitor-specific links.
   *
   * @returns {object} - The payload formatted for Slack notification.
   */
  createSlackData(notification, message, monitor, heartbeat, baseURL) {
    const title = "Uptime Kuma Alert"; // Default title for the notification

    // Check if the monitor object is present, otherwise log and set fallback values
    if (!monitor || !monitor.name) {
      completeLogDebug("Monitor object is null or missing 'name' property", {
        monitor,
      });
      monitor = { name: "Unknown Monitor", id: "fallback-id" }; // Fallback to generic monitor data
    }

    // Determine the status icon and message based on heartbeat data
    const statusIcon = heartbeat && heartbeat.status === UP ? "🟢" : "🔴";
    const statusMessage =
      heartbeat && heartbeat.status === UP ? "is back online!" : "went down!";
    const colorBased =
      heartbeat && heartbeat.status === UP ? "#2eb886" : "#e01e5a"; // Set color based on status

    // Log the start of Slack data construction
    completeLogDebug(`Starting Slack data construction`, {
      notification,
      message,
      monitor,
      heartbeat,
      baseURL,
    });

    // Basic structure for Slack message payload
    const data = {
      text: `${statusIcon} ${monitor.name} ${statusMessage}`, // Preview message Slack APP
      channel: notification.slackchannel, // The channel where the notification will be sent
      username: notification.slackusername || "Uptime Kuma (bot)", // The bot's username
      icon_emoji: notification.slackiconemo || ":robot_face:", // The bot's icon emoji
      attachments: [], // DO NOT USE!!! --> Optional attachments for richer messages
    };

    completeLogDebug(`Initialized basic Slack message structure`, {
      data,
    });

    // If heartbeat data is available and rich message format is enabled, construct a detailed message
    if (heartbeat && notification.slackrichmessage) {
      data.attachments.push({
        color: colorBased, // Message color based on monitor status
        blocks: this.buildBlocks(baseURL, monitor, heartbeat, title, message), // Rich content blocks
      });

      completeLogDebug(`Rich message format applied to Slack notification`, {
        color: colorBased,
        blocks: data.attachments[0].blocks,
      });
    } else {
      // If no heartbeat or rich message is disabled, fallback to a simple text message
      data.text = `${title}\n${message}`;
      completeLogInfo(
        `Simple text message format applied to Slack notification`,
        {
          text: data.text,
        }
      );
    }

    // Log the final Slack data payload
    completeLogDebug(`Final Slack data payload constructed`, {
      data,
    });

    return data; // Return the constructed data payload for sending
  }

  /**
   * Builds action buttons for the Slack message to allow user interactions with the monitor.
   * This includes buttons to visit the Uptime Kuma dashboard and the monitor's address (if available and valid).
   *
   * @param {string} baseURL - The base URL of the Uptime Kuma instance used to generate monitor-specific links.
   * @param {object} monitor - The monitor object containing details like ID, name, and address.
   *
   * @returns {Array} - An array of button objects to be included in the Slack message payload.
   */
  buildActions(baseURL, monitor) {
    const actions = []; // Initialize an empty array to hold the action buttons

    // Log the start of the action button creation process
    completeLogDebug(`Starting action button creation`, {
      baseURL,
      monitor,
    });

    // Check if baseURL is provided and create the Uptime Kuma dashboard button
    if (baseURL) {
      const uptimeButton = {
        type: "button", // Slack button type
        text: { type: "plain_text", text: "Visit Uptime Kuma" }, // Button label
        value: "Uptime-Kuma", // Button value (for interaction tracking, if necessary)
        url: `${baseURL}${getMonitorRelativeURL(monitor.id)}`, // Construct the monitor-specific URL
      };

      actions.push(uptimeButton); // Add the button to the actions array

      // Log the Uptime Kuma button that was added
      completeLogDebug(`Uptime Kuma button added`, {
        button: uptimeButton,
      });
    }

    // Extract the monitor's address (if available) and check its validity
    const address = this.extractAddress(monitor);
    if (address) {
      try {
        const validURL = new URL(address); // Try to create a URL object from the address

        // Exclude URLs that end with reserved ports (commonly used for DNS or DoH)
        if (!validURL.href.endsWith(":53") && !validURL.href.endsWith(":853")) {
          const monitorButton = {
            type: "button", // Slack button type
            text: { type: "plain_text", text: `Visit ${monitor.name}` }, // Button label with monitor name
            value: "Site", // Button value (for interaction tracking)
            url: validURL.href, // Valid URL as the destination for the button
          };

          actions.push(monitorButton); // Add the monitor button to the actions array

          // Log the monitor button that was added
          completeLogDebug(`Monitor button added`, {
            button: monitorButton,
          });
        } else {
          // Log the exclusion of the address due to reserved ports (53 and 853)
          completeLogDebug(`Address excluded due to reserved port`, {
            address: validURL.href,
          });
        }
      } catch (e) {
        // Log an error if the address format is invalid
        completeLogError(
          `Invalid URL format: Can be ignored for certain monitor types, such as PING or TCP Port`,
          {
            address,
            error: e.message,
          }
        );
      }
    } else {
      // Log when no valid address is found for the monitor
      completeLogDebug(
        `No valid address found for monitor: Can be ignored for certain monitor types, such as MQTT, POSTGRES, MYSQL, MONGODB and REDIS`,
        {
          monitor,
        }
      );
    }

    // Log the final actions array, which will be included in the Slack message
    completeLogDebug(`Final actions array constructed`, {
      actions,
    });

    return actions; // Return the array of action buttons
  }

  /**
   * Constructs the Slack message blocks, including the header, monitor details, and actions.
   * Adds additional information such as monitor status, timezone, and local time to the message.
   *
   * @param {string} baseURL - The base URL of Uptime Kuma, used for constructing monitor-specific links.
   * @param {object} monitor - The monitor object containing details like name, status, and tags.
   * @param {object} heartbeat - Heartbeat data object that provides status and timestamp information.
   * @param {string} title - The title of the message (typically the alert title).
   * @param {string} body - The main content of the message (typically a detailed description or status update).
   *
   * @returns {Array<object>} - An array of Slack message blocks, including headers, monitor details, and action buttons.
   */
  buildBlocks(baseURL, monitor, heartbeat, title, body) {
    const blocks = []; // Initialize an array to hold the message blocks

    // Log the creation of the message header
    completeLogDebug(`Building message header block`, {
      title,
    });

    // Create and add the header block with the message title
    blocks.push({
      type: "header",
      text: { type: "plain_text", text: title },
    });

    // Determine monitor status (UP or DOWN) and clean the message content for display
    const statusMessage = heartbeat.status === UP ? "Online" : "Offline";
    const cleanedMsg = body.replace(/\[.*?\]\s*\[.*?\]\s*/, "").trim(); // Remove any bracketed segments from the message
    const timezoneInfo = this.getAllInformationFromTimezone(heartbeat.timezone);
    const continent = timezoneInfo.continent;
    const country = timezoneInfo.country;
    const localTimezone = timezoneInfo.localTimezone;

    // Format the local date, time, and day based on the heartbeat data and timezone
    const localDay = this.formatDay(
      heartbeat.localDateTime,
      heartbeat.timezone
    );
    const localDate = this.formatDate(
      heartbeat.localDateTime,
      heartbeat.timezone
    );
    const localTime = this.formatTime(
      heartbeat.localDateTime,
      heartbeat.timezone
    );

    // Log monitor status and timezone-related information
    completeLogDebug(`Formatted monitor information`, {
      statusMessage,
      localDay,
      localDate,
      localTime,
      country,
    });

    // Define the priority order for tag types, ensuring both lowercase and uppercase tags are handled
    const priorityOrder = {
      P0: 1,
      P1: 2,
      P2: 3,
      P3: 4,
      P4: 5,
      p0: 1,
      p1: 2,
      p2: 3,
      p3: 4,
      p4: 5,
      internal: 6,
      external: 6,
    };

    // Function to retrieve the priority of a tag based on its name
    const getTagPriority = (tagName) => {
      // Match the priority pattern (P0, p0, P1, p1, etc.)
      const match = tagName.match(/^([pP]\d)/);
      if (match) {
        // Return the priority from the defined order or 7 if it's an unrecognized priority tag
        return priorityOrder[match[1]] || 7;
      }
      // Log a warning if the tag doesn't match the expected pattern
      completeLogDebug(
        `Tag '${tagName}' doesn't match a known priority pattern. Defaulting to priority 7.`
      );
      return 7; // Default priority for unrecognized tags
    };

    // Sort tags by their name and the predefined priority
    const sortedTags = monitor.tags
      ? monitor.tags.sort((a, b) => {
          const priorityA = getTagPriority(a.name);
          const priorityB = getTagPriority(b.name);

          // Log the priorities being compared for debugging
          completeLogDebug(
            `Comparing priorities: ${a.name} (Priority: ${priorityA}) vs ${b.name} (Priority: ${priorityB})`
          );

          return priorityA - priorityB;
        })
      : [];

    // Create the display text from the sorted tags, handling the case where no tags are present
    const tagText = sortedTags.length
      ? sortedTags.map((tag) => tag.name).join(", ")
      : "No tags";

    // Log the sorted tags and display text for debugging
    completeLogDebug("Sorted tags for display", {
      sortedTags: sortedTags.map((tag) => tag.name), // Only display the names in the log for clarity
      tagText,
      totalTags: sortedTags.length, // Optionally log the number of tags for extra context
    });

    // Add a section block with monitor details such as name, status, timezone, and tags
    blocks.push({
      type: "section",
      fields: [
        {
          type: "mrkdwn",
          text: `*Monitor Information:*\n  - *Monitor:* ${monitor.name}\n  - *Status:* ${statusMessage}`,
        },
        {
          type: "mrkdwn",
          text: `*Location Details:*\n  - *Continent:* ${continent}\n  - *Country:* ${country}\n  - *Time Zone:* ${localTimezone}`,
        },
        {
          type: "mrkdwn",
          text: `*Date and Time:*\n  - *Day:* ${localDay}\n  - *Date:* ${localDate}\n  - *Time:* ${localTime}`,
        },
        {
          type: "mrkdwn",
          text: `*Tags:*\n  - ${tagText || "No tags available"}`,
        },
        {
          type: "mrkdwn",
          text: `*Details:*\n  - ${cleanedMsg || "No details available"}`,
        },
      ],
    });

    // Log before adding action buttons
    completeLogDebug(`Building action buttons`, {
      baseURL,
      monitor,
    });

    // Add action buttons (e.g., visit Uptime Kuma or monitor URL) if available
    const actions = this.buildActions(baseURL, monitor);
    if (actions.length) {
      blocks.push({ type: "actions", elements: actions }); // Add buttons as an "actions" block

      // Log the added action buttons
      completeLogDebug(`Action buttons added to message blocks`, {
        actions,
      });
    } else {
      // Log when no action buttons are added
      completeLogInfo(`No action buttons to add`);
    }

    // Log the final structure of the message blocks
    completeLogDebug(`Final Slack message blocks constructed`, {
      blocks,
    });

    return blocks; // Return the constructed blocks for Slack message
  }

  /**
   * Formats a UTC time string into a readable local day string.
   * Converts the UTC time to the specified timezone and formats it as the full day name (e.g., "Monday").
   *
   * @param {string} utcTime - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string} - The formatted local day string (e.g., "Monday").
   * @throws {Error} - Throws an error if the time formatting fails.
   */
  formatDay(utcTime, timezone) {
    try {
      // Convert UTC time to the specified timezone and format the day as a full weekday name
      const formattedDay = dayjs
        .utc(utcTime)
        .utcOffset(timezone) // Apply the desired timezone offset
        .format("dddd"); // "dddd" represents the full weekday name (e.g., "Monday")

      // Log the successful formatting of the day
      completeLogDebug(`Formatted local day string`, {
        utcTime,
        timezone,
        formattedDay,
      });

      return formattedDay;
    } catch (error) {
      // Log the error if formatting fails
      completeLogError(`Failed to format local day`, {
        utcTime,
        timezone,
        error: error.message,
      });

      throw new Error("Day formatting failed.");
    }
  }

  /**
   * Formats a UTC time string into a readable local date string.
   * Converts the UTC time to the specified timezone and formats it as a human-readable date (e.g., "Dec 31, 2024").
   *
   * @param {string} utcTime - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string} - The formatted local date string (e.g., "Dec 31, 2024").
   * @throws {Error} - Throws an error if the time formatting fails.
   */
  formatDate(utcTime, timezone) {
    try {
      // Convert UTC time to the specified timezone and format the date
      const formattedDate = dayjs
        .utc(utcTime)
        .utcOffset(timezone) // Apply the desired timezone offset
        .format("MMM DD, YYYY"); // "MMM DD, YYYY" formats date as "Dec 31, 2024"

      // Log the successful formatting of the date
      completeLogDebug(`Formatted local date string`, {
        utcTime,
        timezone,
        formattedDate,
      });

      return formattedDate;
    } catch (error) {
      // Log the error if formatting fails
      completeLogError(`Failed to format local date`, {
        utcTime,
        timezone,
        error: error.message,
      });

      throw new Error(`Date formatting failed.`);
    }
  }

  /**
   * Formats a UTC time string into a readable local time string.
   * Converts the UTC time to the specified timezone and formats it as a 24-hour time string (e.g., "15:30:00").
   *
   * @param {string} utcTime - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string} - The formatted local time string (e.g., "15:30:00").
   * @throws {Error} - Throws an error if the time formatting fails.
   */
  formatTime(utcTime, timezone) {
    try {
      // Convert UTC time to the specified timezone and format the time in 24-hour format
      const formattedTime = dayjs
        .utc(utcTime)
        .utcOffset(timezone) // Apply the desired timezone offset
        .format("HH:mm:ss"); // "HH:mm:ss" formats time as "15:30:00"

      // Log the successful formatting of the time
      completeLogDebug(`Formatted local time string`, {
        utcTime,
        timezone,
        formattedTime,
      });

      return formattedTime;
    } catch (error) {
      // Log the error if formatting fails
      completeLogError(`Failed to format local time`, {
        utcTime,
        timezone,
        error: error.message,
      });

      throw new Error(`Time formatting failed.`);
    }
  }

  /**
   * Converts a timezone string into the corresponding continent, country, and local timezone.
   * This function retrieves the mapping for a given timezone string from predefined sets of continent names,
   * country names, and local timezones. If the timezone is not found, it returns "Unknown" for all values
   * and logs a warning.
   *
   * @param {string} timezone - The timezone string (e.g., "Europe/Amsterdam").
   *                              The timezone string should follow the IANA timezone format (e.g., "Asia/Tokyo", "America/New_York").
   * @returns {Object} - An object containing the corresponding continent, country, and local timezone.
   *                     If the timezone is not found in the mappings, all values will be "Unknown".
   * @throws {Error} - Throws an error if the provided timezone is invalid or if there is an issue with the mapping process.
   *
   * @description
   * This function uses the mappings stored in `timezoneToContinent`, `timezoneToCountry`, and `timezoneToLocalTimezone`
   * to look up the continent, country, and local timezone associated with the provided timezone string.
   * If the timezone is found in the mappings, it returns the corresponding continent, country, and local timezone.
   * If the timezone is not found, it returns "Unknown" for all values and logs a warning message.
   * The function also logs the successful conversion or missing mapping at different log levels (info or warning).
   */
  getAllInformationFromTimezone(timezone) {
    // Mapping of timezone strings to their respective continent names
    const timezoneToContinent = {
      "Europe/Amsterdam": "Europe",
      // More will be added when the script is done.
    };

    // Mapping of timezone strings to their respective country names
    const timezoneToCountry = {
      "Europe/Amsterdam": "Netherlands",
      // More will be added when the script is done.
    };

    // Mapping of timezone strings to their respective local timezones
    const timezoneToLocalTimezone = {
      "Europe/Amsterdam": "Central European Time (CET)",
      // More will be added when the script is done.
    };

    // Log the timezone conversion process
    completeLogDebug(
      `Converting timezone: ${timezone} to continent, country, and local timezone`
    );

    // Get the continent, country, and local timezone from the mappings, or default to "Unknown"
    const continent = timezoneToContinent[timezone] || "Unknown";
    const country = timezoneToCountry[timezone] || "Unknown";
    const localTimezone = timezoneToLocalTimezone[timezone] || "Unknown";

    // If any of the values is unknown, log a warning
    if (
      continent === "Unknown" &&
      country === "Unknown" &&
      localTimezone === "Unknown"
    ) {
      completeLogWarn(
        `Timezone: ${timezone} not found in the mappings. Returning "Unknown" for continent, country, and local timezone`
      );
    } else {
      completeLogInfo(
        `Timezone: ${timezone} corresponds to continent: ${continent}, country: ${country}, local timezone: ${localTimezone}`
      );
    }

    return { continent, country, localTimezone }; // Corrected variable name
  }

  /**
   * Handles migration of a deprecated Slack button URL to the primary base URL if needed.
   * If the primary base URL is not set, it will migrate the provided deprecated URL to the primary base URL setting.
   *
   * This function checks whether a `primaryBaseURL` is already configured. If it is not configured, it updates
   * the settings by setting the `primaryBaseURL` to the provided deprecated URL.
   *
   * @param {string} url - The deprecated URL that is being checked and potentially migrated.
   *                        This URL could be in an older format or pointing to an outdated resource.
   *
   * @throws {Error} - Throws an error if there is an issue with setting the new primary base URL.
   *
   * @returns {void} - This function does not return any value. It performs an asynchronous update to the settings.
   *
   * @description
   * The function is designed to handle the migration of deprecated Slack button URLs to a more current primary base URL.
   * If a primary base URL is already set, no action is taken. If not, it will update the settings to use the deprecated URL
   * as the new primary base URL. This is especially useful when migrating from old configurations or updating legacy URLs.
   */
  static async deprecateURL(url) {
    // Retrieve the current primary base URL from the settings (if any)
    const currentPrimaryBaseURL = await setting("primaryBaseURL");

    // Log the process of checking the deprecated URL for migration
    completeLogInfo(`Checking URL: ${url} for migration to primary base URL`);

    // If no primary base URL is set, attempt to migrate the deprecated URL
    if (!currentPrimaryBaseURL) {
      completeLogInfo(
        "No primary base URL set, migrating the deprecated URL..."
      );

      try {
        // Attempt to set the deprecated URL as the new primary base URL
        await setSettings("general", {
          primaryBaseURL: url,
        });
        completeLogInfo(`Successfully migrated the deprecated URL to: ${url}`);
      } catch (error) {
        // If an error occurs while setting the primary base URL, log the error
        completeLogError(
          `Error occurred while migrating the URL: ${error.message}`
        );
        // Optionally, throw the error to be handled by the caller, or provide fallback behavior
        throw new Error(`Failed to migrate URL: ${error.message}`);
      }
    } else {
      // If the primary base URL is already set, no migration is needed
      completeLogInfo(
        "Primary base URL is already set, no migration required."
      );
    }
  }
}

module.exports = Slack;
