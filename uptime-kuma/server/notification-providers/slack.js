// Required Dependencies
const NotificationProvider = require("./notification-provider");
const axios = require("axios");
const { setSettings, setting } = require("../util-server");
const { getMonitorRelativeURL } = require("../../src/util");
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
   * country names, and local timezones. If the timezone is not found, it returns "Unknown" for all values.
   *
   * @param {string} timezone - The timezone string (e.g., "Europe/Amsterdam").
   * @returns {Object}        - An object containing the corresponding continent, country, and local timezone.
   */
  getAllInformationFromTimezone(timezone) {
    const timezoneToInfo = {
      "Europe/Amsterdam": ["Europe", "Netherlands", "Central European Time"],
      "Europe/Andorra": ["Europe", "Andorra", "Central European Time"],
      "Europe/Belgrade": ["Europe", "Serbia", "Central European Time"],
      // Add more timezones as needed
    };

    // Retrieve the corresponding information for the given timezone, default to "Unknown" if not found
    const [
      continent = "Unknown",
      country = "Unknown",
      localTimezone = "Unknown",
    ] = timezoneToInfo[timezone] ?? [];

    // Log the result with detailed information
    if (logLevelsEnabled.debug) {
      const logMessage = `Timezone: ${timezone}, Continent: ${continent}, Country: ${country}, Local Timezone: ${localTimezone}`;
      completeLogDebug(logMessage);
    }

    // Log warning if the timezone is not found
    if (continent === "Unknown" && logLevelsEnabled.warn) {
      completeLogWarn(`Timezone not found in mappings: ${timezone}`);
    }

    return { continent, country, localTimezone };
  }

  /**
   * Formats a UTC time string into a readable local day string.
   * Converts the UTC time to the specified timezone and formats it as the full weekday name.
   *
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local day string (e.g., "Monday").
   */
  formatDay(utcTime, timezone) {
    if (!utcTime || !timezone) {
      if (logLevelsEnabled.error) {
        completeLogDebug(
          "Invalid input: Both utcTime and timezone are required."
        );
      }
      return null;
    }

    return dayjs(utcTime).tz(timezone).format("dddd");
  }

  /**
   * Formats a UTC time string into a readable local date string.
   * Converts the UTC time to the specified timezone and formats it as a readable date.
   *
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local date string (e.g., "Dec 31, 2024").
   */
  formatDate(utcTime, timezone) {
    if (!utcTime || !timezone) {
      if (logLevelsEnabled.error) {
        completeLogDebug(
          "Invalid input: Both utcTime and timezone are required."
        );
      }
      return null;
    }

    return dayjs.utc(utcTime).tz(timezone).format("MMM DD, YYYY");
  }

  /**
   * Formats a UTC time string into a readable local time string.
   * Converts the UTC time to the specified timezone and formats it as a 24-hour time string.
   *
   * @param {string} utcTime  - The UTC time to be formatted (ISO 8601 string format).
   * @param {string} timezone - The timezone to which the UTC time should be converted (e.g., "Europe/Amsterdam").
   * @returns {string}        - The formatted local time string (e.g., "15:30:00").
   */
  formatTime(utcTime, timezone) {
    if (!utcTime || !timezone) {
      if (logLevelsEnabled.error) {
        completeLogDebug(
          "Invalid input: Both utcTime and timezone are required."
        );
      }
      return null;
    }

    return dayjs(utcTime).tz(timezone).format("HH:mm:ss");
  }

  /**
   * Constructs the Slack message blocks, including the header, monitor details, and actions.
   * Adds additional information such as monitor status, timezone, and local time to the message.
   *
   * @param {string} baseURL   - The base URL of Uptime Kuma, used for constructing monitor-specific links.
   * @param {object} monitor   - The monitor object containing details like name, status, and tags.
   * @param {object} heartbeat - Heartbeat data object that provides status and timestamp information.
   * @param {string} title     - The title of the message (typically the alert title).
   * @returns {Array<object>}  - An array of Slack message blocks, including headers, monitor details, and action buttons.
   */
  buildBlocks(baseURL, monitor, heartbeat, title) {
    const blocks = []; // Initialize an array to hold the message blocks

    try {
      // Log the creation of the message header with the title
      completeLogDebug(`Building message header block`, { title });

      // Create and add the header block with the message title
      blocks.push({
        type: "header",
        text: { type: "plain_text", text: title },
      });

      // Determine the appropriate status message based on the heartbeat status
      let statusMessage;

      // Switch statement to handle different heartbeat statuses
      switch (heartbeat.status) {
        case 0:
          // DOWN: The heartbeat status indicates the system is down
          statusMessage = "went down!";
          break;
        case 1:
          // UP: The heartbeat status indicates the system is back online
          statusMessage = "is back online!";
          break;
        case 2:
          // PENDING: The heartbeat status indicates the system is in a pending state
          statusMessage = "is pending...";
          break;
        case 3:
          // MAINTENANCE: The heartbeat status indicates the system is under maintenance
          statusMessage = "is under maintenance!";
          break;
        default:
          // If the heartbeat status is unrecognized, set status to 'UNKNOWN'
          statusMessage = "status unknown";
          break;
      }

      // Retrieve the monitor's information and only process if available.
      // Log the initial monitor object for debugging purposes.
      completeLogDebug("Monitor object received:", monitor);

      // Get the monitor type, trimming any extra spaces or returning null if not available.
      const monitorType = monitor.type ? monitor.type.trim() : null;
      completeLogDebug("Monitor Type:", monitorType);

      // Get the monitor port, ensuring it's a valid number and converting to string if valid, or return null if not available.
      const monitorPort =
        monitor.port && typeof monitor.port === "number"
          ? String(monitor.port)
          : null;
      completeLogDebug("Monitor Port:", monitorPort);

      // Get the monitor interval (in seconds), trimming any extra spaces, or returning null if not available.
      // Add " Seconds" to the value if available.
      const monitorInterval = monitor.interval
        ? String(monitor.interval).trim() + " Seconds"
        : null;
      completeLogDebug("Monitor Interval:", monitorInterval);

      // Get the maximum retries for the monitor, trimming any extra spaces, or returning null if not available.
      const monitorMaxretries = monitor.maxretries
        ? String(monitor.maxretries).trim()
        : null;
      completeLogDebug("Monitor Max Retries:", monitorMaxretries);

      // Get the monitor's resend interval (in failures), trimming extra spaces or returning null if not available.
      // Add " Failures" to the value if available.
      const monitorResendInterval = monitor.resendInterval
        ? String(monitor.resendInterval).trim() + " Failures"
        : null;
      completeLogDebug("Monitor Resend Interval:", monitorResendInterval);

      // Get the description of the monitor, trimming extra spaces, or returning null if not available.
      const monitorDescription = monitor.description
        ? monitor.description.trim()
        : null;
      completeLogDebug("Monitor Description:", monitorDescription);

      // Get the monitor's keyword, trimming extra spaces, or returning null if not available.
      const monitorKeyword = monitor.keyword ? monitor.keyword.trim() : null;
      completeLogDebug("Monitor Keyword:", monitorKeyword);

      // Get the monitor's invert keyword, trimming extra spaces or returning null if not available.
      const monitorInvertKeyword =
        typeof monitor.invertKeyword === "string"
          ? monitor.invertKeyword.trim()
          : null;
      completeLogDebug("Monitor Invert Keyword:", monitorInvertKeyword);

      // Get the monitor's upside-down flag, trimming extra spaces or returning null if not available.
      // Note: There was a mistake in calling `trim`. The function should be `.trim()`, not `trim`.
      const monitorUpsideDown = monitor.upsideDown
        ? String(monitor.upsideDown).trim()
        : null;
      completeLogDebug("Monitor Upside Down:", monitorUpsideDown);

      // Get the monitor's TLS ignore flag, trimming any extra spaces or returning null if not available.
      const monitorIgnoreTLS = monitor.ignoreTls
        ? String(monitor.ignoreTls).trim()
        : null;
      completeLogDebug("Monitor Ignore TLS:", monitorIgnoreTLS);

      // Check if the heartbeat message is available and not "N/A", trim any extra spaces, or return null if not available.
      const monitorDetails = heartbeat.msg
        ? heartbeat.msg.trim() === "N/A"
          ? null
          : heartbeat.msg.trim()
        : null;
      completeLogDebug("Monitor Details:", monitorDetails);

      // Format the local day, date, and time based on the heartbeat data and timezone
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

      // Log monitor status and timezone-related information for debugging
      completeLogDebug(`Formatted monitor information`, {
        statusMessage,
        localDay,
        localDate,
        localTime,
        timezoneInfo,
      });

      /**
       * Get the priority of a tag based on its name.
       * The priority order handles both lowercase and uppercase tag names.
       *
       * @param {string} tagName - The name of the tag.
       * @returns {number}       - The priority value (lower is higher priority).
       */
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
        external: 6, // 'internal' and 'external' share the same priority
      };

      /**
       * Get the priority of a given tag.
       * This function handles known patterns and assigns a default priority for unrecognized tags.
       *
       * @param {string} tagName - The name of the tag to check.
       * @returns {number}       - The tag's priority (default to 7 if unknown).
       */
      const getTagPriority = (tagName) => {
        // Check if the tag name exists in the priority map
        if (priorityOrder.hasOwnProperty(tagName)) {
          return priorityOrder[tagName];
        }

        // If the tag name matches a known pattern (e.g., P0, p1), assign the corresponding priority
        const match = tagName.match(/^([pP]\d)/);
        if (match) {
          return priorityOrder[match[1]] || 7; // Default to 7 for unrecognized priority patterns
        }

        // Log the unrecognized tag for debugging purposes
        completeLogDebug(
          `Tag '${tagName}' doesn't match a known priority pattern. Defaulting to priority 7.`
        );
        return 7; // Default priority for unrecognized tags
      };

      // Sort tags by their predefined priority and generate display text.
      const sortedTags = monitor.tags
        ? monitor.tags.sort((a, b) => {
            const priorityA = getTagPriority(a.name); // Get priority for the first tag
            const priorityB = getTagPriority(b.name); // Get priority for the second tag

            // Log the comparison of priorities for debugging
            completeLogDebug(
              `Comparing priorities: ${a.name} (Priority: ${priorityA}) vs ${b.name} (Priority: ${priorityB})`
            );

            return priorityA - priorityB; // Sort tags by ascending priority
          })
        : [];

      // Generate the display text from sorted tags, handle empty tags
      const tagText = sortedTags.length
        ? sortedTags.map((tag) => tag.name).join("\n - ")
        : null; // Title-value with newline

      // Log the results of sorting and the generated display text
      completeLogDebug("Tags sorted successfully.", {
        sortedTags: sortedTags.map((tag) => tag.name), // Log only the tag names for clarity
        tagText, // Display text for the tags
        totalTags: sortedTags.length, // Total number of tags
      });

      /**
       * Formats a section of the message based on the provided title, value, and group settings.
       * The formatting style is determined by the `groupSettings` parameter, which controls how
       * the title and value are displayed in the resulting string.
       *
       * @param {string} title          - The title to be displayed for the section.
       * @param {string} value          - The content or value associated with the section.
       * @param {string} groupSettings  - A setting that dictates the formatting style for the section.
       * @returns {string}              - The formatted section text according to the specified group setting.
       */
      function formatSection(title, value, groupSettings) {
        // Log the title, value, and groupSettings passed to the function for debugging purposes
        completeLogDebug(
          "Formatting section with title:",
          title,
          "value:",
          value,
          "groupSettings:",
          groupSettings
        );

        // Switch-case to handle different group settings for formatting
        switch (groupSettings) {
          case "setting-00":
            // Format: Title-value with no newline
            completeLogDebug(
              "Applied 'setting-00': Title-value with no newline"
            );
            return `*${title}:* ${value}`;

          case "setting-01":
            // Format: Title-value with a newline after the value
            completeLogDebug(
              "Applied 'setting-01': Title-value with a newline after the value"
            );
            return `*${title}:* ${value}\n`;

          case "setting-02":
            // Format: Title-value with newlines before the title and value
            completeLogDebug(
              "Applied 'setting-02': Title-value with newlines before the title and value"
            );
            return `\n*${title}:*\n${value}`;

          case "setting-03":
            // Format: Title-value with a bullet point before the value
            completeLogDebug(
              "Applied 'setting-03': Title-value with a bullet point before the value"
            );
            return `\n*${title}:*\n - ${value}`;

          case "setting-04":
            // Special case: If value length is greater than 9, use a new format; otherwise, use a simple format
            completeLogDebug(
              "Applied 'setting-04': Value length is",
              value.length,
              "- Check if this is the intended behavior for short values"
            );
            return value.length > 9
              ? `\n*${title}:*\n${value}` // Newline format for long values
              : `\n*${title}:* ${value}`; // Simple format for short values

          case "setting-05":
            // Format: Title-value with newline before the title
            completeLogDebug(
              "Applied 'setting-05': Title-value with newline before the title"
            );
            return `\n*${title}:* ${value}`;

          default:
            // Log and handle unknown settings gracefully by returning a default format
            completeLogDebug(
              "Unknown setting detected. Returning default format for groupSettings:",
              groupSettings,
              "- Returning default format"
            );
            return `*${title}:* ${value}`;
        }
      }

      /**
       * Groups all monitor information into formatted sections based on specific settings.
       * Each section is processed by the `formatSection` function with different formatting rules.
       * The result is an array of formatted sections that will be used to generate a text block.
       */
      const groupMonitor = [
        // Format sections using different settings for various monitor attributes
        monitor.name
          ? formatSection("Monitor", monitor.name, "setting-00")
          : null,
        statusMessage
          ? formatSection("Status", statusMessage, "setting-00")
          : null,
        monitorType ? formatSection("Type", monitorType, "setting-00") : null,
        monitorPort ? formatSection("Port", monitorPort, "setting-00") : null,
        monitorInterval
          ? formatSection("Interval", monitorInterval, "setting-00")
          : null,
        monitorMaxretries
          ? formatSection("Retries", monitorMaxretries, "setting-00")
          : null,
        monitorResendInterval
          ? formatSection(
              "Resend Notification After",
              monitorResendInterval,
              "setting-00"
            )
          : null,

        timezoneInfo.continent
          ? formatSection("Continent", timezoneInfo.continent, "setting-05")
          : null,
        timezoneInfo.country
          ? formatSection("Country", timezoneInfo.country, "setting-00")
          : null,
        timezoneInfo.localTimezone
          ? formatSection("Time-zone", timezoneInfo.localTimezone, "setting-00")
          : null,
        localDay ? formatSection("Day", localDay, "setting-00") : null,
        localDate ? formatSection("Date", localDate, "setting-00") : null,
        localTime ? formatSection("Time", localTime, "setting-00") : null,

        tagText ? formatSection("Tags", tagText, "setting-03") : null,

        monitorDescription
          ? formatSection("Description", monitorDescription, "setting-02")
          : null,

        monitorKeyword
          ? formatSection("Keyword", monitorKeyword, "setting-05")
          : null,
        monitorInvertKeyword
          ? formatSection("Invert Keyword", monitorInvertKeyword, "setting-05")
          : null,
        monitorUpsideDown
          ? formatSection("Upside Down", monitorUpsideDown, "setting-05")
          : null,
        monitorIgnoreTLS
          ? formatSection("Ignore TLS", monitorIgnoreTLS, "setting-05")
          : null,

        monitorDetails
          ? formatSection("Details", monitorDetails, "setting-04")
          : null,
      ].filter(Boolean); // Remove null values to avoid adding unnecessary sections

      // Join the formatted sections with newlines to create a complete text block
      const blockText = groupMonitor.join("\n");

      // Push the formatted block of text to the blocks array for further use (e.g., in a Slack message)
      blocks.push({
        type: "section",
        text: {
          type: "mrkdwn",
          text: blockText,
        },
      });

      // Add action buttons if available
      const actions = this.buildActions(baseURL, monitor);
      if (actions.length) {
        blocks.push({ type: "actions", elements: actions });
        completeLogDebug(`Action buttons added`, { actions });
      } else {
        completeLogInfo(`No action buttons available to add`);
      }

      // Log the final Slack message blocks construction
      completeLogDebug(`Final Slack message blocks constructed`, { blocks });

      return blocks; // Return the constructed blocks
    } catch (error) {
      // Log error if the block construction fails
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
   * Creates the payload for a Slack message, which may include rich content based on heartbeat data.
   * Depending on the notification configuration and the heartbeat status, it constructs either
   * a simple text message or a detailed rich message for Slack.
   *
   * @param {object} notification   - Configuration object containing Slack notification settings (e.g., channel, username).
   * @param {string} message        - The main content of the notification message.
   * @param {object|null} monitor   - The monitor object containing details (optional). If absent, a default fallback will be used.
   * @param {object|null} heartbeat - Heartbeat data for the monitor (optional). Determines the status for the message.
   * @param {string} baseURL        - The base URL of Uptime Kuma, used to construct monitor-specific links.
   * @returns {object}              - The formatted payload ready for sending as a Slack message.
   */
  createSlackData(notification, message, monitor, heartbeat, baseURL) {
    const title = "Status Report"; // Default title for the notification

    // Fallback to default monitor values if the monitor object is null or missing a 'name' property
    if (!monitor || !monitor.name) {
      completeLogDebug(`Monitor object is null or missing 'name'`, { monitor });
      monitor = { name: "Unknown Monitor", id: "fallback-id" }; // Default monitor values
    }

    // Determine the appropriate status icon, status message, and color based on heartbeat status
    let statusIcon, statusMessage, colorBased;

    // Switch statement to handle different heartbeat statuses
    switch (heartbeat.status) {
      case 0:
        // DOWN: The system is down; use a red icon and message
        statusIcon = "🔴"; // Red circle icon for 'DOWN'
        statusMessage = "went down!";
        colorBased = "#e01e5a"; // Red color for 'DOWN' status
        break;
      case 1:
        // UP: The system is back online; use a green icon and message
        statusIcon = "🟢"; // Green circle icon for 'UP'
        statusMessage = "is back online!";
        colorBased = "#2eb886"; // Green color for 'UP' status
        break;
      case 2:
        // PENDING: The system is in a pending state; use a yellow icon and message
        statusIcon = "🟡"; // Yellow circle icon for 'PENDING'
        statusMessage = "is pending...";
        colorBased = "#f0a500"; // Yellow color for 'PENDING' status
        break;
      case 3:
        // MAINTENANCE: The system is under maintenance; use a blue icon and message
        statusIcon = "⚙️"; // Gear icon for 'MAINTENANCE'
        statusMessage = "is under maintenance!";
        colorBased = "#2196F3"; // Blue color for 'MAINTENANCE' status
        break;
      default:
        // If the heartbeat status is unrecognized, set icon and message to 'UNKNOWN'
        statusIcon = "❓"; // Question mark icon for 'UNKNOWN'
        statusMessage = "status unknown";
        colorBased = "#808080"; // Grey color for 'UNKNOWN' status
        break;
    }

    // Log the start of Slack message construction, including key parameters
    completeLogDebug(`Starting Slack data construction`, {
      notification,
      message,
      monitor,
      heartbeat,
      baseURL,
    });

    // Initialize the basic Slack message structure (text, channel, username, icon)
    const data = {
      text: `${statusIcon} ${monitor.name} ${statusMessage}`, // Main message text
      channel: notification.slackchannel, // Slack channel from configuration
      username: notification.slackusername || "Uptime Kuma (bot)", // Default username if not specified
      icon_emoji: notification.slackiconemo || ":robot_face:", // Default emoji if not specified
      attachments: [], // Slack attachments (optional, used for rich message content)
    };

    completeLogDebug(`Initialized basic Slack message structure`, { data });

    // If rich message format is enabled and heartbeat data is available, create detailed blocks
    if (heartbeat && notification.slackrichmessage) {
      try {
        // Construct the rich message blocks with additional monitor and heartbeat information
        const blocks = this.buildBlocks(
          baseURL,
          monitor,
          heartbeat,
          title,
          message
        );
        data.attachments.push({
          color: colorBased, // Color based on monitor status
          blocks, // Attach rich message blocks
        });

        completeLogDebug(`Rich message format applied`, {
          color: colorBased,
          blocks,
        });
      } catch (error) {
        // If there was an error building the rich message, fall back to a simple text message
        completeLogError(`Failed to build rich message blocks`, {
          error: error.message,
        });
        data.text = `${title}\n${message}`; // Fallback to simple text format
      }
    } else {
      // If rich message format is disabled or no heartbeat data, use a simple text message
      data.text = `${title}\n${message}`;
      completeLogInfo(`Simple text format applied`, { text: data.text });
    }

    // Log the final constructed Slack data payload before returning
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
