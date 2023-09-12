using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using GMHooker;

namespace TSIMPH
{
    public static class Conviences
    {


        public static string SavePrefix { get; private set; } = "";

        public static void AddSavePrefix(string prf)
        {
            if (SavePrefix == "")
            {
                SavePrefix = prf;
            }
            else
            {
                SavePrefix = SavePrefix + "_" + prf;
            }
        }


        public static string DecompileGML(this UndertaleCode code, UndertaleData data)
        {


            return Decompiler.Decompile(code, new GlobalDecompileContext(data, false));
        }

        public static void AddAudioFolder(int currentaudiogroup, int audiogroup, string folder, UndertaleData data)
        {
            //iterate through all .wavs in the specified folder
            foreach (string file in Directory.GetFiles(folder, "*.wav"))
            {
                data.AddSound(currentaudiogroup, audiogroup, file);
            }
        }


        public static UndertaleRoom.GameObject AddObjectToLayer(this UndertaleRoom room, UndertaleData data, string objectname, string layername)
        {
            data.GeneralInfo.LastObj++;
            UndertaleRoom.GameObject obj = new UndertaleRoom.GameObject()
            {
                InstanceID = data.GeneralInfo.LastObj,
                ObjectDefinition = data.GameObjects.ByName(objectname),
                X = 0,
                Y = 0
            };

            room.Layers.First(layer => layer.LayerName.Content == layername).InstancesData.Instances.Add(obj);

            room.GameObjects.Add(obj);

            return obj;
        }

        public static void PrependCode(string name, string gml, UndertaleData data)
        {
            data.HookCode(name, gml + "\n#orig#()");
        }


        public static UndertaleCode CreateCode(this UndertaleData data, string name, string gml, ushort arguments = 0)
        {
            UndertaleCode code = new UndertaleCode();
            code.Name = data.Strings.MakeString(name);
            try
            {
                code.AppendGML(gml, data);
            }
            catch (Exception) { };
            code.ArgumentsCount = arguments;

            data.Code.Add(code);

            return code;
        }

        public static void ReplaceBuiltInFunction(string name, string og_name, string gml, ushort arguments, UndertaleData data)
        {
            UndertaleCode hookCode = data.CreateLegacyScript(name, gml, arguments).Code;

            foreach (UndertaleCode dataCode in data.Code)
            {
                if (dataCode.ParentEntry is not null || dataCode == hookCode)
                    continue;
                

                
                data.HookAsm(dataCode.Name.Content, (code, locals) => {
                    AsmCursor cursor = new(data, code, locals);
                    while (cursor.GotoNext($"call.i {og_name}(argc={arguments})"))
                        cursor.Replace($"call.i {name}(argc={arguments})");
                });
            }
        }
        
        
        public static UndertaleRoom CreateBlankLevelRoom(string roomname, UndertaleData data)
        {
            UndertaleRoom copyme_room = data.Rooms.First(room => room.Name.Content == "level_basic_copy_me");

            if (copyme_room == null)
            {
                throw new NullReferenceException("Unable to find: level_basic_copy_me!");
            }
            else
            {
                UndertaleRoom newroom = new UndertaleRoom();
                newroom.Name = data.Strings.MakeString(roomname);
                newroom.Width = copyme_room.Width;
                newroom.Height = copyme_room.Height;
                newroom.BackgroundColor = copyme_room.BackgroundColor;
                newroom.Flags = copyme_room.Flags;

                for (int i = 0; i < copyme_room.Views.Count; i++)
                {
                    UndertaleRoom.View copyview = copyme_room.Views[i];
                    newroom.Views[i] = new UndertaleRoom.View()
                    {
                        Enabled = copyview.Enabled,
                        BorderX = copyview.BorderX,
                        BorderY = copyview.BorderY,
                        ObjectId = copyview.ObjectId,
                        PortHeight = copyview.PortHeight,
                        PortWidth = copyview.PortWidth,
                        PortX = copyview.PortX,
                        PortY = copyview.PortY,
                        ViewHeight = copyview.ViewHeight,
                        ViewWidth = copyview.ViewWidth,
                        ViewX = copyview.ViewX,
                        ViewY = copyview.ViewY,
                        SpeedX = copyview.SpeedX,
                        SpeedY = copyview.SpeedY

                    };
                }

                uint largest_layerid = 0;

                // Find the largest layer id
                // Shamelessly stolen from UMT source
                foreach (UndertaleRoom Room in data.Rooms)
                {
                    foreach (UndertaleRoom.Layer Layer in Room.Layers)
                    {
                        if (Layer.LayerId > largest_layerid)
                            largest_layerid = Layer.LayerId;
                    }
                }

                foreach (UndertaleRoom.Layer copylayer in copyme_room.Layers)
                {
                    UndertaleRoom.Layer layer = new UndertaleRoom.Layer() //thanks to config for making my code actually good :P
                    {
                        LayerId = largest_layerid++, //maybe??
                        LayerName = copylayer.LayerName,
                        LayerType = copylayer.LayerType,
                        IsVisible = copylayer.IsVisible,
                        LayerDepth = copylayer.LayerDepth,
                    };
                    layer.Data = (UndertaleRoom.Layer.LayerData)Activator.CreateInstance(copylayer.Data.GetType()); //again thanks to config!!!
                    layer.EffectProperties = copylayer.EffectProperties;

                    layer.EffectProperties = new UndertaleSimpleList<UndertaleRoom.EffectProperty>();

                    if (layer.LayerType == UndertaleRoom.LayerType.Background)
                    {
                        layer.BackgroundData.AnimationSpeed = copylayer.BackgroundData.AnimationSpeed;
                        layer.BackgroundData.AnimationSpeedType = copylayer.BackgroundData.AnimationSpeedType;
                        layer.BackgroundData.CalcScaleX = copylayer.BackgroundData.CalcScaleX;
                        layer.BackgroundData.CalcScaleY = copylayer.BackgroundData.CalcScaleY;
                        layer.BackgroundData.Color = copylayer.BackgroundData.Color;
                        layer.BackgroundData.FirstFrame = copylayer.BackgroundData.FirstFrame;
                        layer.BackgroundData.Foreground = copylayer.BackgroundData.Foreground;
                        layer.BackgroundData.Sprite = copylayer.BackgroundData.Sprite;
                        layer.BackgroundData.Stretch = copylayer.BackgroundData.Stretch;
                        layer.BackgroundData.TiledHorizontally = copylayer.BackgroundData.TiledHorizontally;
                        layer.BackgroundData.TiledVertically = copylayer.BackgroundData.TiledVertically;
                        layer.BackgroundData.Visible = copylayer.BackgroundData.Visible;
                    }

                    // Somewhat shamefully stolen from UMT source
                    if (layer.LayerType == UndertaleRoom.LayerType.Assets)
                    {
                        // create a new pointer list (if null)
                        layer.AssetsData.LegacyTiles ??= new UndertalePointerList<UndertaleRoom.Tile>();
                        // create new sprite pointer list (if null)
                        layer.AssetsData.Sprites ??= new UndertalePointerList<UndertaleRoom.SpriteInstance>();
                        // create new sequence pointer list (if null)
                        layer.AssetsData.Sequences ??= new UndertalePointerList<UndertaleRoom.SequenceInstance>();
                    }
                    else if (layer.LayerType == UndertaleRoom.LayerType.Tiles)
                    {
                        // create new tile data (if null)
                        layer.TilesData.TileData ??= Array.Empty<uint[]>();
                    }

                    newroom.Layers.Add(layer);

                    newroom.UpdateBGColorLayer();

                    newroom.SetupRoom(false);
                }

                newroom.GridHeight = 60;

                newroom.GridWidth = 60;


                newroom.SetupRoom(false);

                return newroom;
            }
        }


    }
}