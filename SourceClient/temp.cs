using GmmlPatcher;
using UndertaleModLib;
using System.Reflection;
using System.Runtime.Remoting;
using Intermediary;

namespace GMMLHotReloadingAPI
{
    public class GameMakerMod : IGameMakerMod
    {
        public void Load(int audioGroup, UndertaleData data, ModData currentMod)
        {
            if (audioGroup != 0) return;
        }

        private static void Reload()
        {
            // make a appdomain
            AppDomain domain = AppDomain.CreateDomain("ReloadDomain");



            // AppDomain domain = AppDomain.CreateDomain("MyDomain");
            // ObjectHandle handle = domain.CreateInstance("Intermediary", "Intermediary.IntermediaryClass");

            IIntermediary intermediary = (IIntermediary)handle.Unwrap();
            intermediary.Execute("Unloadable.dll", "Unloadable.UnloadableClass", "Greet");
            AppDomain.Unload(domain);
        }
    }
   
}
