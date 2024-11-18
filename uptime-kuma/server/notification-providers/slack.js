// Required Dependencies
const NotificationProvider = require("./notification-provider");
const axios = require("axios");
const { setSettings, setting } = require("../util-server");
const { getMonitorRelativeURL, UP } = require("../../src/util");
const dayjs = require("dayjs");
const utc = require("dayjs/plugin/utc");
const timezone = require("dayjs/plugin/timezone");

// Extend dayjs with UTC and timezone plugins for proper time formatting
// This ensures that dayjs can handle time zone conversions and UTC time correctly.
dayjs.extend(utc);
dayjs.extend(timezone);

// Global configuration object for controlling log levels and compact logs
// Each key represents a different log level, and the value determines whether
// logs for that level are enabled or disabled.
const logLevelsEnabled = {
  debug: false, // Set to true to enable debug logs. Default is false.
  info: true, // Set to false to disable info logs. Default is true.
  warn: true, // Set to false to disable warning logs. Default is true.
  error: true, // Set to false to disable error logs. Default is true.
  compactLogs: true, // Set to true to enable compact logs by default
};

/**
 * Gets the corresponding color code for the specified log level.
 *
 * @param {string} logLevel - The log level (e.g., 'DEBUG', 'INFO', 'WARN', 'ERROR').
 * @returns {string}        - The color code for the given log level, or white if unknown.
 *
 * Colors are used for styling the logs based on their severity:
 * - DEBUG: Purple
 * - INFO:  Cyan
 * - WARN:  Yellow
 * - ERROR: Red
 */
function getLogLevelColor(logLevel) {
  const colors = {
    DEBUG: "\x1b[35m",
    INFO: "\x1b[36m",
    WARN: "\x1b[33m",
    ERROR: "\x1b[31m",
  };
  // Return the color for the given log level or default to white if unknown
  return colors[logLevel.toUpperCase()] || "\x1b[37m"; // Default to white
}

/**
 * Logs a debug level message if 'debug' log level is enabled in the configuration.
 *
 * @param {string} message            - The message to be logged.
 * @param {any} [additionalInfo=null] - Optional additional information to be logged alongside the message.
 */
function completeLogDebug(message, additionalInfo = null) {
  // Check if debug logging is enabled
  if (logLevelsEnabled.debug) {
    logMessage("DEBUG", message, additionalInfo);
  }
}

/**
 * Logs an info level message if 'info' log level is enabled in the configuration.
 *
 * @param {string} message            - The message to be logged.
 * @param {any} [additionalInfo=null] - Optional additional information to be logged alongside the message.
 */
function completeLogInfo(message, additionalInfo = null) {
  // Check if info logging is enabled
  if (logLevelsEnabled.info) {
    logMessage("INFO", message, additionalInfo);
  }
}

/**
 * Logs a warn level message if 'warn' log level is enabled in the configuration.
 *
 * @param {string} message            - The message to be logged.
 * @param {any} [additionalInfo=null] - Optional additional information to be logged alongside the message.
 */
function completeLogWarn(message, additionalInfo = null) {
  // Check if warn logging is enabled
  if (logLevelsEnabled.warn) {
    logMessage("WARN", message, additionalInfo);
  }
}

/**
 * Logs an error level message if 'error' log level is enabled in the configuration.
 *
 * @param {string} message            - The message to be logged.
 * @param {any} [additionalInfo=null] - Optional additional information to be logged alongside the message.
 */
function completeLogError(message, additionalInfo = null) {
  // Check if error logging is enabled
  if (logLevelsEnabled.error) {
    logMessage("ERROR", message, additionalInfo);
  }
}

/**
 * General function to format and log the message with the appropriate log level.
 *
 * @param {string} logLevel           - The log level to be used in the message.
 * @param {string} message            - The main log message.
 * @param {any} [additionalInfo=null] - Optional additional information (e.g., stack trace, context).
 */
function logMessage(logLevel, message, additionalInfo = null) {
  const color = getLogLevelColor(logLevel); // Get the color for the current log level
  const timestamp = dayjs().format(); // Get the current timestamp in ISO 8601 format

  // Log the message, prefixing it with the appropriate log level and timestamp
  let logOutput = `${color}[${logLevel}] ${timestamp} - ${message}\x1b[0m`;

  // If additional info is provided (e.g., error stack trace), log it as well
  if (additionalInfo) {
    logOutput += `\n${JSON.stringify(additionalInfo, null, 2)}`;
  }

  console.log(logOutput); // Output the log to the console
}

/**
 * Generates and logs a complete log message with timestamp, script name, log level, and optional additional information.
 *
 * The log message includes color formatting for different sections (timestamp, script name, log level) and can include
 * additional information in either compact or indented format, depending on the configuration.
 *
 * @param {string} logLevel           - The log level (e.g., 'DEBUG', 'INFO', 'WARN', 'ERROR').
 * @param {string} message            - The main log message.
 * @param {any} [additionalInfo=null] - Optional additional information (e.g., stack trace or context) to include in the log.
 */
function logMessage(logLevel, message, additionalInfo = null) {
  // Automatically detect the system's time zone using the Intl API
  // This ensures the timestamp is accurate for the system's local time zone.
  const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;

  // Get the current time in a readable format, adjusted for the detected time zone.
  // The format used is ISO 8601, which includes the date, time, and timezone offset.
  const timestamp = dayjs().tz(timezone).format("YYYY-MM-DDTHH:mm:ssZ");

  // Hardcoded script name for the log. This could be dynamically set if needed.
  const scriptName = "slack.js";

  // Define color codes for different parts of the log message to improve readability in the terminal.
  const colors = {
    timestamp: "\x1b[36m", // Cyan for timestamp
    scriptName: "\x1b[38;5;13m", // Bright Purple for script name
    reset: "\x1b[0m", // Reset color to default after each section
    white: "\x1b[37m", // White for log level and other static text
  };

  // Construct the log message with the timestamp, script name, and log level.
  // Each section of the message is colorized based on the defined color codes.
  let logMessage = `${colors.timestamp}${timestamp}${colors.reset} `;
  logMessage += `${colors.white}[${colors.scriptName}${scriptName}${colors.white}]${colors.reset} `;
  logMessage += `${getLogLevelColor(logLevel)}${logLevel}:${
    colors.reset
  } ${message}`;

  // If additional information is provided, include it in the log message.
  if (additionalInfo) {
    // Depending on the 'compactLogs' setting, format the additional info:
    // - If compactLogs is enabled, the additional info will be in a single-line, non-indented format.
    // - If compactLogs is disabled, the additional info will be pretty-printed with indentation for better readability.
    const additionalInfoString = logLevelsEnabled.compactLogs
      ? JSON.stringify(additionalInfo) // Compact format (no indentation)
      : JSON.stringify(additionalInfo, null, 2); // Indented format (pretty print)

    // Append the additional information to the log message.
    logMessage += ` | Additional Info: ${additionalInfoString}`;
  }

  // Output the constructed log message to the console.
  // This message includes the log level, timestamp, script name, main message, and any additional info.
  console.log(logMessage);
}

class Slack extends NotificationProvider {
  name = "slack";

  /**
   * Validates the configuration object for Slack notifications to ensure all required fields are present.
   * Throws an error if required fields are missing. Sets a default icon if no custom icon is provided.
   *
   * @param {object} notification - The Slack notification configuration object.
   * @throws {Error}              - Throws an error if any required fields are missing or invalid.
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

    // Check each required field and log errors if any are missing
    requiredFields.forEach(({ field, message }) => {
      if (!notification[field]) {
        completeLogError(
          `Missing required field in Slack notification configuration`,
          {
            field, // Name of the missing field
            message, // Error message to provide context
            notification, // Current state of the notification object
          }
        );
        throw new Error(message); // Halt execution if a field is missing
      }
    });

    // Log success when all required fields are validated
    completeLogDebug(
      `All required fields are present in Slack notification configuration`,
      {
        requiredFields: requiredFields.map((field) => field.field),
      }
    );

    // Handle Slack icon emoji: set default or confirm custom
    if (!notification.slackiconemo) {
      // No custom icon provided, setting default icon
      notification.slackiconemo = ":robot_face:";
      completeLogDebug(`Default Slack icon emoji set`, {
        icon: notification.slackiconemo,
      });
    } else {
      // Custom icon is provided, logging confirmation
      completeLogDebug(`Custom Slack icon emoji provided`, {
        icon: notification.slackiconemo,
      });
    }
  }

  /**
   * Converts a timezone string to the corresponding continent, country, and local timezone.
   * Retrieves the mapping for a given timezone string from predefined sets of continent names,
   * country names, and local timezones. If the timezone is not found, it returns "Unknown" for all values
   * and logs a warning.
   *
   * @param {string} timezone - The timezone string (e.g., "Europe/Amsterdam").
   *                            Must follow the IANA timezone format (e.g., "Asia/Tokyo", "America/New_York").
   * @returns {Object}        - An object containing the corresponding continent, country, and local timezone.
   *                            If the timezone is not found, all values are set to "Unknown".
   * @throws {Error}          - Throws an error if the provided timezone is invalid or if fetching the mapping fails.
   */
  getAllInformationFromTimezone(timezone) {
    // Mappings for timezone strings to respective continent, country, and local timezone names
    const timezoneToContinent = {
      "Europe/Amsterdam": "Europe",
      // More will be added when the script is done.
    };

    const timezoneToCountry = {
      "Europe/Amsterdam": "Netherlands",
      // More will be added when the script is done.
    };

    const timezoneToLocalTimezone = {
      "Europe/Amsterdam": "Central European Time",
      // More will be added when the script is done.
    };

    // Log the start of the timezone conversion process
    completeLogDebug(
      `Converting timezone: ${timezone} to continent, country, and local timezone.`,
      { timezone }
    );

    // Retrieve mappings or default to "Unknown" if not found
    const continent = timezoneToContinent[timezone] || "Unknown";
    const country = timezoneToCountry[timezone] || "Unknown";
    const localTimezone = timezoneToLocalTimezone[timezone] || "Unknown";

    // Log a warning if all values are unknown
    if (
      continent === "Unknown" &&
      country === "Unknown" &&
      localTimezone === "Unknown"
    ) {
      completeLogWarn(`Timezone: ${timezone} not found in mappings.`, {
        continent,
        country,
        localTimezone,
      });
    } else {
      // Log the successfully mapped values
      completeLogDebug(`Mapped timezone: ${timezone}`, {
        continent,
        country,
        localTimezone,
      });
    }

    // Return the results as an object
    return { continent, country, localTimezone };
  }

  /**
   * Formats a UTC time string into a readable local day string.
   * Converts the UTC time to the specified timezone and formats it as the full weekday name (e.g., "Monday").
   *
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local day string (e.g., "Monday").
   * @throws {Error}          - Throws an error if formatting the day fails.
   */
  formatDay(utcTime, timezone) {
    try {
      // Validate inputs
      if (!utcTime || !timezone) {
        const errorMsg = "Invalid input: utcTime and timezone are required.";
        completeLogError(errorMsg, { utcTime, timezone });
        throw new Error(errorMsg);
      }

      // Convert UTC time to the specified timezone and format the day as the full weekday name
      const formattedDay = dayjs(utcTime).tz(timezone).format("dddd"); // "dddd" gives the full weekday name (e.g., "Monday")

      // Log the successful day formatting
      completeLogDebug(`Formatted local day string successfully`, {
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
   * Converts the UTC time to the specified timezone and formats it as a readable date (e.g., "Dec 31, 2024").
   *
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local date string (e.g., "Dec 31, 2024").
   * @throws {Error}          - Throws an error if formatting the date fails.
   */
  formatDate(utcTime, timezone) {
    try {
      // Validate inputs
      if (!utcTime || !timezone) {
        const errorMsg =
          "Invalid input: Both utcTime and timezone are required.";
        completeLogError(errorMsg, { utcTime, timezone });
        throw new Error(errorMsg);
      }

      // Convert UTC time to the specified timezone and format the date
      const formattedDate = dayjs
        .utc(utcTime)
        .tz(timezone)
        .format("MMM DD, YYYY"); // "MMM DD, YYYY" formats the date as "Dec 31, 2024"

      // Log the successful date formatting
      completeLogDebug(`Formatted local date string successfully`, {
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
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local time string (e.g., "15:30:00").
   * @throws {Error}          - Throws an error if formatting the time fails.
   */
  formatTime(utcTime, timezone) {
    try {
      // Validate inputs
      if (!utcTime || !timezone) {
        const errorMsg =
          "Invalid input: Both utcTime and timezone are required.";
        completeLogError(errorMsg, { utcTime, timezone });
        throw new Error(errorMsg);
      }

      // Convert UTC time to the specified timezone and format the time in 24-hour format
      const formattedTime = dayjs(utcTime).tz(timezone).format("HH:mm:ss"); // "HH:mm:ss" formats the time as "15:30:00"

      // Log the successful time formatting
      completeLogDebug(`Formatted local time string successfully`, {
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
   * Constructs the Slack message blocks, including the header, monitor details, and actions.
   * Adds additional information such as monitor status, timezone, and local time to the message.
   *
   * @param {string} baseURL   - The base URL of Uptime Kuma, used for constructing monitor-specific links.
   * @param {object} monitor   - The monitor object containing details like name, status, and tags.
   * @param {object} heartbeat - Heartbeat data object that provides status and timestamp information.
   * @param {string} title     - The title of the message (typically the alert title).
   * @param {string} body      - The main content of the message (typically a detailed description or status update).
   * @returns {Array<object>}  - An array of Slack message blocks, including headers, monitor details, and action buttons.
   */
  buildBlocks(baseURL, monitor, heartbeat, title, body) {
    const blocks = []; // Initialize an array to hold the message blocks

    try {
      // Log the creation of the message header
      completeLogDebug(`Building message header block`, { title });

      // Create and add the header block with the message title
      blocks.push({
        type: "header",
        text: { type: "plain_text", text: title },
      });

      // Determine monitor status and clean the message content
      const statusMessage = heartbeat.status === UP ? "Online" : "Offline";
      const cleanedMsg = body.replace(/\[.*?\]\s*\[.*?\]\s*/, "").trim();

      // Format the local date, time, and day based on the heartbeat data
      const timezoneInfo = this.getAllInformationFromTimezone(
        heartbeat.timezone
      );
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
        timezoneInfo,
      });

      // Define the priority order for tag types, ensuring both lowercase and uppercase tags are handled.
      const priorityOrder = {
        P0: 1,
        P1: 2,
        P2: 3,
        P3: 4,
        P4: 5, // Uppercase priority tags
        p0: 1,
        p1: 2,
        p2: 3,
        p3: 4,
        p4: 5, // Lowercase priority tags
        internal: 6,
        external: 6, // 'internal' and 'external' have the same priority
      };

      /**
       * Get the priority of a tag based on its name.
       *
       * @param {string} tagName - The name of the tag.
       * @returns {number}       - The priority value (lower is higher priority).
       */
      const getTagPriority = (tagName) => {
        // Check if the tag name exists explicitly in the priority order map
        if (priorityOrder.hasOwnProperty(tagName)) {
          return priorityOrder[tagName];
        }

        // Check if the tag matches the expected priority pattern (e.g., P0, p1)
        const match = tagName.match(/^([pP]\d)/);
        if (match) {
          return priorityOrder[match[1]] || 7; // Default to 7 if the pattern is recognized but not in the map
        }

        // Log a warning if the tag does not match any known pattern
        completeLogDebug(
          `Tag '${tagName}' doesn't match a known priority pattern. Defaulting to priority 7.`
        );
        return 7; // Default priority for unrecognized tags
      };

      /**
       * Sort tags by their predefined priority and generate display text.
       *
       * The function handles cases where:
       * - Tags are empty (returns a default "No tags available" message).
       * - Tags have custom or unrecognized names (assigns them a default priority).
       */
      const sortedTags = monitor.tags
        ? monitor.tags.sort((a, b) => {
            const priorityA = getTagPriority(a.name); // Get priority for the first tag
            const priorityB = getTagPriority(b.name); // Get priority for the second tag

            // Log the comparison of priorities for debugging
            completeLogDebug(
              `Comparing priorities: ${a.name} (Priority: ${priorityA}) vs ${b.name} (Priority: ${priorityB})`
            );

            return priorityA - priorityB; // Sort by ascending priority
          })
        : [];

      // Generate the display text from the sorted tags, handling cases with no tags.
      const tagText = sortedTags.length
        ? sortedTags.map((tag) => tag.name).join(", ") // Concatenate tag names with commas
        : "No tags available"; // Default message when there are no tags

      // Log the results of the sorting and the generated display text for debugging
      completeLogInfo("Tags sorted successfully.", {
        sortedTags: sortedTags.map((tag) => tag.name), // Only log tag names for clarity
        tagText, // Display text for the tags
        totalTags: sortedTags.length, // Total number of tags in the result
      });

      // Add a section block with monitor details
      blocks.push({
        type: "section",
        fields: [
          {
            type: "mrkdwn",
            text: `*Monitor:* ${monitor.name}\n*Status:* ${statusMessage}`,
          },
          {
            type: "mrkdwn",
            text: `*Continent:* ${timezoneInfo.continent}\n*Country:* ${timezoneInfo.country}\n*Time-zone:* ${timezoneInfo.localTimezone}`,
          },
          {
            type: "mrkdwn",
            text: `*Day:* ${localDay}\n*Date:* ${localDate}\n*Time:* ${localTime}`,
          },
          {
            type: "mrkdwn",
            text: `*Tags:*\n  - ${tagText}`,
          },
          {
            type: "mrkdwn",
            text: `*Details:*\n  - ${cleanedMsg || "No details available"}`,
          },
        ],
      });

      // Add action buttons if available
      const actions = this.buildActions(baseURL, monitor);
      if (actions.length) {
        blocks.push({ type: "actions", elements: actions });
        completeLogDebug(`Action buttons added`, { actions });
      } else {
        completeLogInfo(`No action buttons available to add`);
      }

      completeLogDebug(`Final Slack message blocks constructed`, { blocks });

      return blocks; // Return the constructed blocks
    } catch (error) {
      completeLogError(`Failed to build Slack message blocks`, {
        error: error.message,
      });
      throw new Error("Slack message block construction failed.");
    }
  }

  /**
   * Builds action buttons for the Slack message to allow user interactions with the monitor.
   * This includes buttons to visit the Uptime Kuma dashboard and the monitor's address (if available and valid).
   *
   * @param {string} baseURL - The base URL of the Uptime Kuma instance used to generate monitor-specific links.
   * @param {object} monitor - The monitor object containing details like ID, name, and address.
   * @returns {Array}        - An array of button objects to be included in the Slack message payload.
   */
  buildActions(baseURL, monitor) {
    const actions = []; // Initialize an empty array to hold the action buttons

    // Log the start of the action button creation process
    completeLogDebug(`Starting action button creation`, { baseURL, monitor });

    // Add Uptime Kuma dashboard button if a valid baseURL is provided
    if (baseURL) {
      try {
        const uptimeButton = {
          type: "button",
          text: { type: "plain_text", text: "Visit Uptime Kuma" },
          value: "Uptime-Kuma",
          url: `${baseURL}${getMonitorRelativeURL(monitor.id)}`,
        };

        actions.push(uptimeButton);
        completeLogDebug(`Uptime Kuma button added`, { button: uptimeButton });
      } catch (e) {
        // Log an error if constructing the URL fails
        completeLogError(`Failed to construct Uptime Kuma button URL`, {
          baseURL,
          monitorId: monitor.id,
          error: e.message,
        });
      }
    }

    // Extract and validate the monitor's address
    const address = this.extractAddress(monitor);
    if (address) {
      try {
        const validURL = new URL(address);

        // Exclude URLs ending with reserved ports (e.g., 22 for SSH, 53/853 for DNS/DoH)
        if (
          !validURL.href.endsWith(":22") &&
          !validURL.href.endsWith(":53") &&
          !validURL.href.endsWith(":853")
        ) {
          const monitorButton = {
            type: "button",
            text: { type: "plain_text", text: `Visit ${monitor.name}` },
            value: "Site",
            url: validURL.href,
          };

          actions.push(monitorButton);
          completeLogDebug(`Monitor button added`, { button: monitorButton });
        } else {
          completeLogDebug(`Address excluded due to reserved port`, {
            address: validURL.href,
          });
        }
      } catch (e) {
        completeLogError(`Invalid URL format`, {
          address,
          monitorName: monitor.name,
          error: e.message,
        });
      }
    } else {
      // Log when no valid address is found for the monitor
      completeLogDebug(
        `No valid address found for monitor. This may apply to non-URL-based monitors (e.g., MQTT, PING).`,
        { monitor }
      );
    }

    // Log the final actions array
    completeLogDebug(`Final actions array constructed`, { actions });

    return actions; // Return the array of action buttons
  }

  /**
   * Creates the payload for the Slack message, optionally including rich content with heartbeat data.
   * Constructs a simple text message or a detailed rich message based on the configuration and heartbeat data.
   *
   * @param {object} notification   - The configuration object for Slack notifications.
   * @param {string} message        - The main content of the notification message.
   * @param {object|null} monitor   - The monitor object containing details (optional).
   * @param {object|null} heartbeat - Heartbeat data for the monitor (optional).
   * @param {string} baseURL        - The base URL of Uptime Kuma used to create monitor-specific links.
   * @returns {object}              - The payload formatted for Slack notification.
   */
  createSlackData(notification, message, monitor, heartbeat, baseURL) {
    const title = "Uptime Kuma Alert"; // Default title for the notification

    // Fallback for missing monitor object
    if (!monitor || !monitor.name) {
      completeLogDebug(`Monitor object is null or missing 'name'`, { monitor });
      monitor = { name: "Unknown Monitor", id: "fallback-id" }; // Default monitor values
    }

    // Determine the status icon, message, and color
    const statusIcon = heartbeat?.status === UP ? "🟢" : "🔴";
    const statusMessage =
      heartbeat?.status === UP ? "is back online!" : "went down!";
    const colorBased = heartbeat?.status === UP ? "#2eb886" : "#e01e5a";

    // Log the start of Slack data construction
    completeLogDebug(`Starting Slack data construction`, {
      notification,
      message,
      monitor,
      heartbeat,
      baseURL,
    });

    // Initialize the basic Slack payload structure
    const data = {
      text: `${statusIcon} ${monitor.name} ${statusMessage}`,
      channel: notification.slackchannel,
      username: notification.slackusername || "Uptime Kuma (bot)",
      icon_emoji: notification.slackiconemo || ":robot_face:",
      attachments: [],
    };

    completeLogDebug(`Initialized basic Slack message structure`, { data });

    // Add rich message format if enabled and heartbeat data is available
    if (heartbeat && notification.slackrichmessage) {
      try {
        const blocks = this.buildBlocks(
          baseURL,
          monitor,
          heartbeat,
          title,
          message
        );
        data.attachments.push({
          color: colorBased,
          blocks,
        });

        completeLogDebug(`Rich message format applied`, {
          color: colorBased,
          blocks,
        });
      } catch (error) {
        // Log any errors encountered during rich message block construction
        completeLogError(`Failed to build rich message blocks`, {
          error: error.message,
        });
        data.text = `${title}\n${message}`; // Fallback to simple text format
      }
    } else {
      // Fallback to simple text format if rich messages are disabled or no heartbeat data
      data.text = `${title}\n${message}`;
      completeLogInfo(`Simple text format applied`, { text: data.text });
    }

    // Log the final Slack data payload
    completeLogDebug(`Final Slack data payload constructed`, { data });

    return data;
  }

  /**
   * Handles migration of a deprecated Slack button URL to the primary base URL if needed.
   * Updates the `primaryBaseURL` setting with the provided deprecated URL if it is not already configured.
   *
   * @param {string} url - The deprecated URL to be checked and potentially migrated.
   *                       This URL could be in an older format or pointing to an outdated resource.
   * @throws {Error}     - Throws an error if there is an issue updating the `primaryBaseURL`.
   * @returns {Promise<void>} - Resolves when the migration process is complete.
   */
  static async deprecateURL(url) {
    try {
      // Retrieve the current primary base URL from the settings
      const currentPrimaryBaseURL = await setting("primaryBaseURL");

      // Log the start of the migration check
      completeLogDebug(`Checking if URL needs migration`, {
        url,
        currentPrimaryBaseURL,
      });

      // Check if migration is required
      if (!currentPrimaryBaseURL) {
        completeLogInfo(
          "No primary base URL is set. Proceeding to migrate the deprecated URL.",
          { url }
        );

        // Attempt to set the deprecated URL as the new primary base URL
        await setSettings("general", { primaryBaseURL: url });

        // Log successful migration
        completeLogInfo(
          `Successfully migrated deprecated URL to primary base URL`,
          {
            newPrimaryBaseURL: url,
          }
        );
      } else {
        // Log that no migration is required
        completeLogInfo(
          "Primary base URL is already configured. No migration needed.",
          {
            currentPrimaryBaseURL,
          }
        );
      }
    } catch (error) {
      // Log and rethrow any errors encountered during the process
      completeLogError(`Failed to migrate deprecated URL`, {
        url,
        error: error.message,
      });
      throw new Error(`Migration failed: ${error.message}`);
    }
  }

  /**
   * Sends a Slack notification with optional detailed blocks if heartbeat data is provided.
   * The message can include a channel notification tag if configured in the notification settings.
   *
   * @param {object} notification   - Slack notification configuration, including webhook URL, channel, and optional settings.
   * @param {string} message        - The content to be sent in the Slack notification.
   * @param {object|null} monitor   - The monitor object containing monitor details (optional).
   * @param {object|null} heartbeat - Heartbeat data to be included in the notification (optional).
   * @returns {Promise<string>}     - A success message indicating the notification was sent successfully.
   * @throws {Error}                - Throws an error if the notification fails or configuration is invalid.
   */
  async send(notification = {}, message, monitor = null, heartbeat = null) {
    const successMessage = "Sent Successfully.";

    try {
      // Validate the provided Slack notification configuration
      this.validateNotificationConfig(notification);
      completeLogDebug(`Slack notification configuration validated`, {
        notification,
      });
    } catch (error) {
      completeLogError(`Slack notification configuration error`, {
        error: error.message,
        notification,
      });
      throw new Error("Notification configuration is invalid.");
    }

    // Append the Slack channel notification tag if configured
    if (notification.slackchannelnotify) {
      message += " <!channel>";
      completeLogInfo(`Channel notification tag appended`, {
        message,
      });
    }

    try {
      // Retrieve the base URL for constructing monitor links
      const baseURL = await setting("primaryBaseURL");
      completeLogDebug(`Retrieved base URL`, { baseURL });

      // Construct the payload for the Slack notification
      const data = this.createSlackData(
        notification,
        message,
        monitor,
        heartbeat,
        baseURL
      );
      completeLogDebug(`Slack notification data constructed`, { data });

      // Process deprecated Slack button URL if specified
      if (notification.slackbutton) {
        await Slack.deprecateURL(notification.slackbutton);
        completeLogWarn(`Processed deprecated Slack button URL`, {
          slackbutton: notification.slackbutton,
        });
      }

      // Send the Slack notification using Axios
      const response = await axios.post(notification.slackwebhookURL, data);
      completeLogInfo(`Slack notification sent successfully`, {
        responseData: response.data,
      });

      return successMessage;
    } catch (error) {
      // Log detailed error information if sending the notification fails
      completeLogError(`Slack notification failed`, {
        errorMessage: error.message,
        errorStack: error.stack,
        response: error.response?.data || "No response data",
        notification,
        constructedData: {
          message,
          monitor,
          heartbeat,
        },
      });

      // Throw a general error for Axios-related issues
      this.throwGeneralAxiosError(error);
    }
  }
}

module.exports = Slack;
