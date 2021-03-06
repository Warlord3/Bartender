//Uncomment to enable debug Messages
#define DEBUG_MSG

#define DEBUG_PRINTER Serial
#ifdef DEBUG_MSG
#define DEBUG_BEGIN(baudrate) DEBUG_PRINTER.begin(baudrate)
#define DEBUG_PRINT(...)                  \
    {                                     \
        DEBUG_PRINTER.print(__VA_ARGS__); \
    }
#define DEBUG_PRINTLN(...)                  \
    {                                       \
        DEBUG_PRINTER.println(__VA_ARGS__); \
    }
#define DEBUG_PRINTF(...)                  \
    {                                      \
        DEBUG_PRINTER.printf(__VA_ARGS__); \
    }
#else
#define DEBUG_BEGIN
#define DEBUG_PRINT(...) \
    {                    \
    }
#define DEBUG_PRINTLN(...) \
    {                      \
    }
#define DEBUG_PRINTF(...) \
    {                     \
    }
#endif