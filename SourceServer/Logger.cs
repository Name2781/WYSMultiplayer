namespace Server
{
    // quickest logger ive wrote
    public static class Logger
    {
        public enum LogLevel
        {
            Info,
            Warn,
            Error,
        }

        public static void Log(string log, LogLevel level = LogLevel.Info)
        {
            switch(level)
            {

                case LogLevel.Error:
                    Console.BackgroundColor = ConsoleColor.Red;
                    Console.ForegroundColor = ConsoleColor.White;
                    break;

                case LogLevel.Warn:
                    Console.BackgroundColor = ConsoleColor.Yellow;
                    Console.ForegroundColor = ConsoleColor.White;
                    break;

                case LogLevel.Info:
                    Console.ForegroundColor = ConsoleColor.White;
                    break;

                default:
                    break;
            }

            Console.Write(log);
            Console.ResetColor();
            Console.Write("\n");
        }
    }
}