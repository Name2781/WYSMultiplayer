
namespace TSIMPH;
public static class GMLKVP
{
    public static Dictionary<string, string> DictionarizeGMLFolder(string gmlfolder)
    {
        Dictionary<string, string> Dict = new Dictionary<string, string>();

        try
        {
            string[] infos = Directory.GetFiles(gmlfolder);

            for (int i = 0; i < infos.Length; i++)
            {
                FileInfo fo = new FileInfo(infos[i]);
                //fo.Name
                if (fo.Extension == ".gml")
                {
                    Console.WriteLine("Reading File: " + fo.Name);
                    Dict.Add(Path.GetFileNameWithoutExtension(fo.Name), File.ReadAllText(infos[i]));
                }
            }
        }
        catch
        {
            return new Dictionary<string, string>();
        }

        return Dict;
    }

    public static bool LoadGMLFolder(this Dictionary<string,string> GMLkvp, string gmlfolder)
    {
        Dictionary<string, string> dict = DictionarizeGMLFolder(gmlfolder);
        foreach (KeyValuePair<string, string> kvp in dict)
        {
            GMLkvp.Add(kvp.Key, kvp.Value);
        }
        return dict.Count != 0;
    }
}