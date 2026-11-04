# ERROR_HANDLING

Current AppException is sealed and UnexpectedAppException is its only subtype. No full taxonomy exists. Target: translate low-level I/O/SQLite/plugin errors at data boundaries; preserve domain validation errors; UI maps failures to safe actionable messages. Retry only safe operations; transaction multi-record changes; fail closed on crypto/archive errors. Never log note content, passwords, keys or attachment bytes.
