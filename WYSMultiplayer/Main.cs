using GmmlPatcher;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using GmmlHooker;
using TSIMPH;

namespace WYSMultiplayer
{
    public class GameMakerMod : IGameMakerMod
    {
        // from snailax source
        public static Dictionary<string, string> GMLkvp = new Dictionary<string, string>();

        public static GlobalDecompileContext? GDC;

        public static bool LoadGMLFolder(string gmlfolder)
        {
            return GMLkvp.LoadGMLFolder(gmlfolder);
        }

        public static UndertaleScript CreateScriptFromKVP(UndertaleData data, string name, string key, ushort arguments)
        {
            return data.CreateLegacyScript(name, GMLkvp[key], arguments);
        }

        // my code
        public void Load(int audioGroup, UndertaleData data, ModData currentMod)
        {
            if (audioGroup != 0) return;
            GDC = new GlobalDecompileContext(data, false);
            //supress vs being stupid (i mean he's not wrong)
            string gmlfolder = Path.Combine(currentMod.path, "GMLSource");

            LoadGMLFolder(gmlfolder);

            UndertaleGameObject mp_player_obj = new UndertaleGameObject();

            mp_player_obj.Name = data.Strings.MakeString("obj_mp_player");

            mp_player_obj.Sprite = data.Sprites.ByName("spr_player");
            mp_player_obj.Persistent = true;

            mp_player_obj.EventHandlerFor(EventType.Create, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Create"], data);

            mp_player_obj.EventHandlerFor(EventType.Other, EventSubtypeOther.User0, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Other_10"], data);

            data.Code.ByName("gml_Object_obj_snaili_eye_Other_10").ReplaceGmlSafe(GMLkvp["gml_Object_obj_snaili_eye_Other_10"], data);

            mp_player_obj.EventHandlerFor(EventType.Step, EventSubtypeStep.Step, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Step_0"], data);

            mp_player_obj.EventHandlerFor(EventType.Draw, EventSubtypeDraw.Draw, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Draw_0"], data);

            data.GameObjects.Add(mp_player_obj);

            UndertaleGameObject multiplayermanager_obj = new UndertaleGameObject();

            multiplayermanager_obj.Name = data.Strings.MakeString("obj_multiplayer_manager");
            multiplayermanager_obj.Persistent = true;

            multiplayermanager_obj.EventHandlerFor(EventType.Step, EventSubtypeStep.Step, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_obj_multiplayer_manager_Step_0"], data);
            multiplayermanager_obj.EventHandlerFor(EventType.Other, EventSubtypeOther.AsyncNetworking, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_obj_multiplayer_manager_Network"], data);

            data.GameObjects.Add(multiplayermanager_obj);

            CreateScriptFromKVP(data, "scr_send_position", "gml_Script_scr_send_position", 6);

            CreateScriptFromKVP(data, "scr_send_player_info", "gml_Script_scr_send_player_info", 5);

            CreateScriptFromKVP(data, "scr_recived_packet", "gml_Script_scr_recived_packet", 2);

            CreateScriptFromKVP(data, "scr_player_join", "gml_Script_scr_player_join", 1);

            CreateScriptFromKVP(data, "scr_host_lpick", "gml_Script_scr_host_lpick", 0);

            data.CreateCode("gml_RoomCC_room_multiplayer_Create", GMLkvp["gml_RoomCC_room_multiplayer_Create"]);

            try
            {

                data.Code.First(code => code.Name.Content == "gml_Object_obj_epilepsy_warning_Create_0")
                    .AppendGML("txt_1 = \"WORKS\"\ntxt_2 = \"The fitness gram pacer test is \na multi stage arobic capacity test.", data);
            }
            // UndertaleModLib is trying to write profile cache but fails, we don't care (i dont care more)
            catch (Exception) { }

            UndertaleRoom mp_room = Conviences.CreateBlankLevelRoom("room_multiplayer", data);

            mp_room.SetupRoom(false);

            mp_room.AddObjectToLayer(data, "obj_multiplayer_manager", "Player");

            mp_room.AddObjectToLayer(data, "obj_player", "Player");

            mp_room.AddObjectToLayer(data, "obj_post_processing_draw", "PostProcessing");

            var bottomWall = mp_room.AddObjectToLayer(data, "obj_wall", "Walls");

            bottomWall.Y = 900;
            bottomWall.ScaleX = 35;

            mp_room.CreationCodeId = data.Code.ByName("gml_RoomCC_room_multiplayer_Create");

            mp_room.SetupRoom(false);


            data.Rooms.Add(mp_room);

            try
            { // vk_ralt, vk_rcontrol
                data.Code.First(code => code.Name.Content == "gml_Object_obj_player_Step_0")
                    .AppendGML("if keyboard_check_pressed(vk_f5)\nscr_fade_to_room(room_multiplayer)\nif (keyboard_check_pressed(vk_f6) && global.isHost)\nscr_host_lpick();", data);
            }
            catch (Exception) { }
        }
    }
}