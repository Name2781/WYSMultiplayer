namespace Server.Types
{
    public class PlayerData
    {
        public byte[]? name { get; set; }
        public byte[]? team { get; set; }
        public byte[]? teamName { get; set; }
        public byte[]? hideTeam { get; set; }
    }

    public class GameObject
    {
        public int id { get; set; }
        public int x = 0;
        public int y = 0;
        public float xscale = 1;
        public float yscale = 1;
    }
}