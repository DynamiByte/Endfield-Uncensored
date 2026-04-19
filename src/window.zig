const std = @import("std");

// Module Imports
const bytegui = @import("bytegui.zig");
const loader = @import("loader.zig");
const app_version = @import("version.zig");
const strings = @import("strings.zig");
pub const c = @import("win32.zig");

const allocator = std.heap.c_allocator;

const ByteGui = bytegui.ByteGui;
const ByteGuiStyle = bytegui.ByteGuiStyle;
const ByteGuiStyleVar_Alpha = bytegui.ByteGuiStyleVar_Alpha;
const ByteGuiWindowFlags_NoBackground = bytegui.ByteGuiWindowFlags_NoBackground;
const ByteGuiWindowFlags_NoDecoration = bytegui.ByteGuiWindowFlags_NoDecoration;
const ByteGuiWindowFlags_NoMove = bytegui.ByteGuiWindowFlags_NoMove;
const ByteGuiWindowFlags_NoNav = bytegui.ByteGuiWindowFlags_NoNav;
const ByteGuiWindowFlags_NoResize = bytegui.ByteGuiWindowFlags_NoResize;
const ByteGuiWindowFlags_NoSavedSettings = bytegui.ByteGuiWindowFlags_NoSavedSettings;
const ByteGuiWindowFlags_NoScrollbar = bytegui.ByteGuiWindowFlags_NoScrollbar;
const ByteGuiWindowFlags_NoScrollWithMouse = bytegui.ByteGuiWindowFlags_NoScrollWithMouse;
const ByteDrawList = bytegui.ByteDrawList;
const ByteFont = bytegui.ByteFont;
const ByteFontConfig = bytegui.ByteFontConfig;
const Ui = bytegui.Ui;
const ByteGuiPlatformWindowConfig = bytegui.ByteGuiPlatformWindowConfig;
const ByteU32 = bytegui.ByteU32;
const ByteVec2 = bytegui.ByteVec2;
const ByteVec4 = bytegui.ByteVec4;
const bgc = bytegui.c;
const TextTexture = Ui.TextTexture;
const embedded_inter_regular = @embedFile("Inter_18pt-Regular.ttf");
const embedded_inter_semibold = @embedFile("Inter_18pt-SemiBold.ttf");
const embedded_jetbrains_mono = @embedFile("JetBrainsMono-Regular.ttf");

// UI Constants And Embedded Assets
const VERSION_STR = app_version.version_str;
const APP_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored");
const WINDOW_CLASS = std.unicode.utf8ToUtf16LeStringLiteral("EndfieldUncensoredGL");
const README_URL = std.unicode.utf8ToUtf16LeStringLiteral("https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md");
const LABEL_LAUNCH = strings.label_launch;
const LABEL_MINIMIZE = strings.label_minimize;
const APP_ICON_RESOURCE_ID: u16 = 1;

const WINDOW_WIDTH = 500;
const WINDOW_HEIGHT = 200;
const CORNER_RADIUS = 15;
const WINDOW_SLIDE_IN_OFFSET = 80.0;
const WINDOW_SLIDE_IN_DURATION = 0.70;
const WINDOW_SLIDE_OUT_OFFSET = 80.0;
const WINDOW_SLIDE_OUT_DURATION = 0.30;

const CLOSE_X = 465.0;
const CLOSE_Y = 2.0;
const CLOSE_W = 30.0;
const CLOSE_H = 30.0;
const CLOSE_Y_OFFSET = 1.8;

const MIN_X = 443.0;
const MIN_Y = 0.0;
const MIN_W = 17.0;
const MIN_H = 32.0;
const MIN_Y_OFFSET = 1.5;

const INFO_X = 7.0;
const INFO_Y = 7.0;
const INFO_W = 20.0;
const INFO_H = 20.0;

const OUTPUT_X = 252.0;
const OUTPUT_Y = 42.0;
const OUTPUT_W = 224.0;
const OUTPUT_H = 115.0;

const VERSION_X = 10.0;
const VERSION_Y = 175.0;

const TOGGLE_X = 290.0;
const TOGGLE_Y = 10.0;
const TOGGLE_W = 140.0;
const TOGGLE_H = 22.0;
const TOGGLE_Y_OFFSET = -1.3;

const LAUNCH_X = 347.0;
const LAUNCH_Y = 150.0;
const LAUNCH_W = 136.0;
const LAUNCH_H = 35.0;

const DRAG_THRESHOLD = 12;
const PROCESS_POLL_MS: u64 = 175;
const LOGO_CANVAS_X = 62.0;
const LOGO_CANVAS_Y = 52.0;
const LOGO_CANVAS_W = 190.0;
const LOGO_CANVAS_H = 100.0;
const LOGO_SUPERSAMPLE = 2.0;
const LOGO_SAMPLE_GRID: u32 = 2;
const BUTTON_LABEL_SUPERSAMPLE = 1.0;
const IDC_ARROW_ID: u16 = 32512;
const IDC_HAND_ID: u16 = 32649;
const embedded_dll = @embedFile("EFUHook");
const LOGO_TEXT_PATH = "M3.37,13.25h7.9V9.68H3.37V7.37H9.68L11.46,5.6V3.82H0V19.45H11.6V15.81H3.37ZM7.52,1.18h.23l.36.62h.52L8.2,1.1A.51.51,0,0,0,8.53.59C8.53.16,8.19,0,7.77,0H7.05V1.8h.47Zm0-.81h.21c.22,0,.34,0,.34.22S8,.84,7.73.84H7.52ZM0,37H3.38V30.8H11V27.24H3.38v-2.3h7.8V21.41H0ZM.59,1.4h.58l.12.4h.49L1.17,0H.61L0,1.8H.48ZM.73.92C.78.74.83.54.88.35h0c0,.18.1.39.15.57l0,.15H.68Zm54.69.55a.82.82,0,0,1-.48-.18l-.27.29a1.19,1.19,0,0,0,.74.26c.47,0,.74-.26,.74-.56A.49.49,0,0,0,55.77.8L55.52.71c-.17-.06-.3-.1-.3-.2s.09-.15.24-.15a.67.67,0,0,1,.4.14L56.1.23A1,1,0,0,0,55.46,0c-.42,0-.71.24-.71.54a.52.52,0,0,0,.39.48l.26.1c.16.06.27.09.27.2S55.59,1.47,55.42,1.47ZM12.46,37h3.39V26.09H12.5l3.35-3.34V21.41H12.46ZM21.35,1.22c0-.22,0-.46-.06-.66h0l.19.39L22,1.8h.48V0H22V.62a6.26,6.26,0,0,0,.06.65h0L21.87.88,21.38,0H20.9V1.8h.45ZM28.45,0H28V1.8h.48ZM39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4ZM41.42,1.08h.65V1.8h.46V0h-.46V.71h-.65V0H41V1.8h.47Zm7,.72h.47V.39h.53V0H47.9V.39h.53Zm-13.59,0a1,1,0,0,0,.65-.22V.79h-.73v.35h.32v.29a.53.53,0,0,1-.19,0,.49.49,0,0,1-.54-.56.5.5,0,0,1,.5-.55.53.53,0,0,1,.36.14l.25-.27A.91.91,0,0,0,34.83,0a.91.91,0,0,0-1,.93A.88.88,0,0,0,34.84,1.84Zm-20.39-.5.21-.26.46.72h.52L14.93.74l.6-.71H15l-.56.7h0V0H14V1.8h.48Zm6.46,29.43h7.9V27.2h-7.9V24.88h6.33L29,23.13v-1.8H17.55V37h11.6V33.33H20.91Zm38.47,0h-.09v.12h.09ZM27.18,16.12V3.87H23.82v9.81L16.9,3.87H13.12v15.6h3.35V9.14l7.35,10.33ZM59.38,31h-.09v.13h.09Zm.56,0h-.18v.11h.18Zm8.89,2H66.91v.46h1.57v.74H66.91v.15l1.82,1.26v-.36l.5-.18V33.68h-.4ZM58.64,21.41V36.9h15.5V21.41Zm3.56,9.26h.22a.56.56,0,0,0,0-.12h.2l-.07.11h.32V31H63v.15h-.13v.25c0,.07,0,.11-.06.13a.36.36,0,0,1-.19,0,.42.42,0,0,0,0-.15h.1s0,0,0,0v-.24h-.39a.64.64,0,0,1-.2.42.63.63,0,0,0-.12-.11.52.52,0,0,0,.16-.31h-.14V31h.15Zm.38.75a.73.73,0,0,0-.18-.16l.1-.08a.55.55,0,0,1,.19.14Zm-1.51-.55v-.15h.45a.75.75,0,0,0-.06-.13l.16-.06s.06.12.08.16l-.08,0h.44v.15h-.55a.37.37,0,0,1,0,.11H62v.07c0,.29,0,.41-.09.46a.2.2,0,0,1-.13.06h-.19a.32.32,0,0,0-.06-.15h.24s0-.11.06-.28h-.32a.65.65,0,0,1-.31.46.45.45,0,0,0-.11-.13.61.61,0,0,0,.28-.59Zm-.87-.26H61v1h-.17V31.5h-.45v.07H60.2Zm-.59,0h.48v.82c0,.08,0,.12-.06.14a.38.38,0,0,1-.2,0,.47.47,0,0,0-.06-.15h.14s0,0,0,0v-.17h-.2a.54.54,0,0,1-.18.35.58.58,0,0,0-.12-.1.61.61,0,0,0,.17-.5Zm-.47,0h.38v.67h-.23v.09h-.15Zm0,2.74L60,31.76h.92l-1.23,2.33h-.57Zm2,2.84-2,.4v-.7l2-.41Zm12.79.41H71.45l-.72-.37V34.37l-.42.16v-.85h-.24v1l.46-.17v1l-1.62.6v.44l-2-1.42v1.38H66V35.21L64,36.6H62.82l-1.67-1.19.62-.46,1.65,1.14L66,34.31v-.15H64.41v-.74H66V33h-2v.18l-.86.6,1,.64v.88l-1.6-1.1-1.47,1v.12l-1.92.41v-.25l1.6-2.76H61l.68-.91h.9l-.32.43H66v-.46h.92v.46h2v.72h.27V32h.84v.94h.46v.6l.2-.08V32.29h.84v.85l.21-.08v-1.3h.84v1l1-.4v2.54l-.84.35V33.57l-.21.08V35.3l-.84.35V34l-.21.08v1.78h2.32Zm-12-1.78.63-.46.86.59v.92Zm.59-1.5L63,33H61.89Zm-2.5-2.58h-.18v.11h.18Zm1.14,3.07h-.21l-.43.83.38-.09v-.1l1-.72-.47-.32ZM42.62,33.2h0ZM34.05,21.39H30.66V37H41.59V33.11H34.05Zm22.86,3.87A4.74,4.74,0,0,0,56,23.72a6.75,6.75,0,0,0-1.4-1.24,6.06,6.06,0,0,0-2-.85,11.64,11.64,0,0,0-2.75-.3h-7.2V33.19l3.4-3.4V25h3.54q4.36,0,4.36,4v.13q0,4-4.36,4H42.63V37h7.22a9.91,9.91,0,0,0,3.22-.48,6.29,6.29,0,0,0,2.22-1.22,5.84,5.84,0,0,0,1.34-1.78,7.62,7.62,0,0,0,.69-2,11.54,11.54,0,0,0,.18-2.09v-.63A11.17,11.17,0,0,0,57.36,27,9.43,9.43,0,0,0,56.91,25.26Zm3.91,5.51h-.45V31h.45Zm0,.36h-.45v.21h.45Zm1.59-.23.1-.08h-.15V31h.19A.55.55,0,0,0,62.41,30.9Zm.17.12h.16v-.2h-.22a.61.61,0,0,1,.15.12Z";
const LOGO_EF_PATH = "M18.298828125 7.857421875 V26.876953125 Q18.298828125 30.111328125 18.087890625 31.4208984375 Q17.876953125 32.73046875 16.83984375 34.1103515625 Q15.802734375 35.490234375 14.1064453125 36.2021484375 Q12.41015625 36.9140625 10.107421875 36.9140625 Q7.55859375 36.9140625 5.607421875 36.0703125 Q3.65625 35.2265625 2.689453125 33.873046875 Q1.72265625 32.51953125 1.546875 31.0166015625 Q1.37109375 29.513671875 1.37109375 24.697265625 V7.857421875 H8.771484375 V29.197265625 Q8.771484375 31.060546875 8.9736328125 31.5791015625 Q9.17578125 32.09765625 9.791015625 32.09765625 Q10.494140625 32.09765625 10.6962890625 31.5263671875 Q10.8984375 30.955078125 10.8984375 28.828125 V7.857421875 Z M37.6875 7.857421875 V36.31640625 H31.201171875 L27.3515625 23.37890625 V36.31640625 H21.1640625 V7.857421875 H27.3515625 L31.5 20.671875 V7.857421875 Z M57.9375 20.267578125 H50.537109375 V15.310546875 Q50.537109375 13.1484375 50.2998046875 12.6123046875 Q50.0625 12.076171875 49.25390625 12.076171875 Q48.33984375 12.076171875 48.09375 12.7265625 Q47.84765625 13.376953125 47.84765625 15.5390625 V28.7578125 Q47.84765625 30.83203125 48.09375 31.46484375 Q48.33984375 32.09765625 49.201171875 32.09765625 Q50.02734375 32.09765625 50.2822265625 31.46484375 Q50.537109375 30.83203125 50.537109375 28.494140625 V24.92578125 H57.9375 V26.033203125 Q57.9375 30.4453125 57.3134765625 32.291015625 Q56.689453125 34.13671875 54.5537109375 35.525390625 Q52.41796875 36.9140625 49.2890625 36.9140625 Q46.037109375 36.9140625 43.927734375 35.736328125 Q41.818359375 34.55859375 41.1328125 32.4755859375 Q40.447265625 30.392578125 40.447265625 26.208984375 V17.89453125 Q40.447265625 14.818359375 40.658203125 13.2802734375 Q40.869140625 11.7421875 41.9150390625 10.318359375 Q42.9609375 8.89453125 44.8154296875 8.0771484375 Q46.669921875 7.259765625 49.078125 7.259765625 Q52.34765625 7.259765625 54.474609375 8.525390625 Q56.6015625 9.791015625 57.26953125 11.6806640625 Q57.9375 13.5703125 57.9375 17.560546875 Z M60.591796875 7.857421875 H72.931640625 V13.552734375 H67.9921875 V18.94921875 H72.615234375 V24.36328125 H67.9921875 V30.62109375 H73.423828125 V36.31640625 H60.591796875 Z M92.07421875 7.857421875 V36.31640625 H85.587890625 L81.73828125 23.37890625 V36.31640625 H75.55078125 V7.857421875 H81.73828125 L85.88671875 20.671875 V7.857421875 Z M110.724609375 16.470703125 H103.8515625 V14.361328125 Q103.8515625 12.884765625 103.587890625 12.48046875 Q103.32421875 12.076171875 102.708984375 12.076171875 Q102.041015625 12.076171875 101.6982421875 12.62109375 Q101.35546875 13.166015625 101.35546875 14.2734375 Q101.35546875 15.697265625 101.7421875 16.41796875 Q102.111328125 17.138671875 103.833984375 18.158203125 Q108.7734375 21.09375 110.056640625 22.974609375 Q111.33984375 24.85546875 111.33984375 29.0390625 Q111.33984375 32.080078125 110.6279296875 33.521484375 Q109.916015625 34.962890625 107.876953125 35.9384765625 Q105.837890625 36.9140625 103.130859375 36.9140625 Q100.16015625 36.9140625 98.0595703125 35.7890625 Q95.958984375 34.6640625 95.30859375 32.923828125 Q94.658203125 31.18359375 94.658203125 27.984375 V26.12109375 H101.53125 V29.583984375 Q101.53125 31.18359375 101.8212890625 31.640625 Q102.111328125 32.09765625 102.849609375 32.09765625 Q103.587890625 32.09765625 103.9482421875 31.517578125 Q104.30859375 30.9375 104.30859375 29.794921875 Q104.30859375 27.28125 103.623046875 26.5078125 Q102.919921875 25.734375 100.16015625 23.923828125 Q97.400390625 22.095703125 96.50390625 21.26953125 Q95.607421875 20.443359375 95.0185546875 18.984375 Q94.4296875 17.525390625 94.4296875 15.2578125 Q94.4296875 11.98828125 95.2646484375 10.4765625 Q96.099609375 8.96484375 97.962890625 8.1123046875 Q99.826171875 7.259765625 102.462890625 7.259765625 Q105.345703125 7.259765625 107.3759765625 8.19140625 Q109.40625 9.123046875 110.0654296875 10.5380859375 Q110.724609375 11.953125 110.724609375 15.345703125 Z M130.5703125 24.521484375 Q130.5703125 28.810546875 130.3681640625 30.5947265625 Q130.166015625 32.37890625 129.1025390625 33.85546875 Q128.0390625 35.33203125 126.228515625 36.123046875 Q124.41796875 36.9140625 122.009765625 36.9140625 Q119.724609375 36.9140625 117.9052734375 36.1669921875 Q116.0859375 35.419921875 114.978515625 33.92578125 Q113.87109375 32.431640625 113.66015625 30.673828125 Q113.44921875 28.916015625 113.44921875 24.521484375 V19.65234375 Q113.44921875 15.36328125 113.6513671875 13.5791015625 Q113.853515625 11.794921875 114.9169921875 10.318359375 Q115.98046875 8.841796875 117.791015625 8.05078125 Q119.6015625 7.259765625 122.009765625 7.259765625 Q124.294921875 7.259765625 126.1142578125 8.0068359375 Q127.93359375 8.75390625 129.041015625 10.248046875 Q130.1484375 11.7421875 130.359375 13.5 Q130.5703125 15.2578125 130.5703125 19.65234375 Z M123.169921875 15.169921875 Q123.169921875 13.18359375 122.9501953125 12.6298828125 Q122.73046875 12.076171875 122.044921875 12.076171875 Q121.46484375 12.076171875 121.1572265625 12.5244140625 Q120.849609375 12.97265625 120.849609375 15.169921875 V28.458984375 Q120.849609375 30.9375 121.0517578125 31.517578125 Q121.25390625 32.09765625 121.9921875 32.09765625 Q122.748046875 32.09765625 122.958984375 31.4296875 Q123.169921875 30.76171875 123.169921875 28.248046875 Z M133.330078125 7.857421875 H138.568359375 Q143.806640625 7.857421875 145.6611328125 8.26171875 Q147.515625 8.666015625 148.6845703125 10.3271484375 Q149.853515625 11.98828125 149.853515625 15.626953125 Q149.853515625 18.94921875 149.02734375 20.091796875 Q148.201171875 21.234375 145.775390625 21.462890625 Q147.97265625 22.0078125 148.728515625 22.921875 Q149.484375 23.8359375 149.6689453125 24.6005859375 Q149.853515625 25.365234375 149.853515625 28.810546875 V36.31640625 H142.98046875 V26.859375 Q142.98046875 24.57421875 142.6201171875 24.029296875 Q142.259765625 23.484375 140.73046875 23.484375 V36.31640625 H133.330078125 Z M140.73046875 12.7265625 V19.0546875 Q141.978515625 19.0546875 142.4794921875 18.7119140625 Q142.98046875 18.369140625 142.98046875 16.48828125 V14.923828125 Q142.98046875 13.5703125 142.4970703125 13.1484375 Q142.013671875 12.7265625 140.73046875 12.7265625 Z M152.71875 7.857421875 H165.05859375 V13.552734375 H160.119140625 V18.94921875 H164.7421875 V24.36328125 H160.119140625 V30.62109375 H165.55078125 V36.31640625 H152.71875 Z M167.677734375 7.857421875 H173.21484375 Q178.576171875 7.857421875 180.4658203125 8.349609375 Q182.35546875 8.841796875 183.33984375 9.966796875 Q184.32421875 11.091796875 184.5703125 12.4716796875 Q184.81640625 13.8515625 184.81640625 17.89453125 V27.861328125 Q184.81640625 31.693359375 184.4560546875 32.9853515625 Q184.095703125 34.27734375 183.19921875 35.0068359375 Q182.302734375 35.736328125 180.984375 36.0263671875 Q179.666015625 36.31640625 177.01171875 36.31640625 H167.677734375 Z M175.078125 12.7265625 V31.447265625 Q176.677734375 31.447265625 177.046875 30.8056640625 Q177.416015625 30.1640625 177.416015625 27.31640625 V16.259765625 Q177.416015625 14.326171875 177.29296875 13.78125 Q177.169921875 13.236328125 176.73046875 12.9814453125 Q176.291015625 12.7265625 175.078125 12.7265625 Z";

const LOGO_PATH_LAYERS = [_]Ui.SvgPathLayer{
    .{ .path = LOGO_TEXT_PATH, .transform = .{ .a = 2.211, .d = 2.211, .e = LOGO_CANVAS_X + 13.0, .f = LOGO_CANVAS_Y + 3.0 } },
    .{ .path = LOGO_EF_PATH, .transform = .{ .a = 0.893583, .d = 0.2, .e = LOGO_CANVAS_X + 11.774814, .f = LOGO_CANVAS_Y + 84.0 } },
};

// UI Animation And Loader State

const ScalarAnim = struct {
    value: f32 = 0.0,
    start: f32 = 0.0,
    target: f32 = 0.0,
    elapsed: f32 = 0.0,
    duration: f32 = 0.18,
    animating: bool = false,
};

const ColorAnim = struct {
    start: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    current: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    target: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    elapsed: f32 = 0.0,
    duration: f32 = 0.12,
    animating: bool = false,
};

const WindowAnimType = enum {
    none,
    slide_in,
    slide_out_close,
    fade_out_minimize,
    fade_in_restore,
};

const WindowAnim = struct {
    typ: WindowAnimType = .none,
    elapsed: f32 = 0.0,
    duration: f32 = 0.0,
    start_pos: c.POINT = std.mem.zeroes(c.POINT),
    end_pos: c.POINT = std.mem.zeroes(c.POINT),
    start_opacity: f32 = 1.0,
    end_opacity: f32 = 1.0,
};

const CloseCountdown = struct {
    const Action = enum {
        close,
        minimize,
    };

    active: bool = false,
    action: Action = .close,
    remaining_seconds: i32 = 0,
    elapsed: f32 = 0.0,
};

const LoaderUiEvent = union(enum) {
    clear_status: void,
    status_line: []u8,
    replace_last_status_line: []u8,
    process_closed: void,
    minimize_after_inject: void,
    close_after_inject: void,
};

const ThreadMutex = if (@hasDecl(std.Thread, "Mutex"))
    std.Thread.Mutex
else
    struct {
        pub fn lock(_: *@This()) void {}
        pub fn unlock(_: *@This()) void {}
    };

const LoaderWorkerState = struct {
    tracked_pid: u32 = 0,
    last_failed_pid: u32 = 0,
    temp_dll_path: ?[]u8 = null,

    fn cleanupTempDll(self: *LoaderWorkerState) void {
        if (self.temp_dll_path) |path| {
            loader.deleteTempDll(allocator, path);
            allocator.free(path);
            self.temp_dll_path = null;
        }
    }

    fn deinit(self: *LoaderWorkerState) void {
        self.cleanupTempDll();
        self.* = .{};
    }
};

var g_hwnd: ?c.HWND = null;
var g_running = true;
var g_window_opacity: f32 = 0.0;

var g_font_ui: ?*ByteFont = null;
var g_font_ui_bold: ?*ByteFont = null;
var g_font_console: ?*ByteFont = null;
var g_font_version: ?*ByteFont = null;
var g_font_launch: ?*ByteFont = null;
var g_font_launch_hover: ?*ByteFont = null;
var g_font_launch_peak: ?*ByteFont = null;
var g_font_toggle: ?*ByteFont = null;
var g_font_toggle_hover: ?*ByteFont = null;
var g_font_toggle_peak: ?*ByteFont = null;

var g_logo_texture: TextTexture = .{};
var g_launch_label_texture: TextTexture = .{};
var g_toggle_label_texture: TextTexture = .{};

var g_output_lines: std.ArrayListUnmanaged([]u8) = .empty;
var g_minimize_on_launch = false;
var g_minimized_by_toggle = false;
var g_game_exe_path: ?[:0]u16 = null;
var g_environ: std.process.Environ = .empty;
var g_launch_btn_enabled = false;
var g_version_display_buf: [64]u8 = undefined;
var g_version_display: []const u8 = VERSION_STR;
var g_loader_thread: ?std.Thread = null;

fn setGuiTrace(_: []const u8) void {}

fn setGuiTraceFmt(comptime fmt: []const u8, args: anytype) void {
    _ = fmt;
    _ = args;
}
var g_loader_control_mutex: ThreadMutex = .{};
var g_loader_events_mutex: ThreadMutex = .{};
var g_loader_should_stop = false;
var g_loader_minimize_on_launch = false;
var g_loader_events: std.ArrayListUnmanaged(LoaderUiEvent) = .empty;

var g_hovered_button: i32 = 0;
var g_pressed_button: i32 = 0;
var g_press_captured = false;
var g_press_canceled = false;
var g_dragging = false;
var g_press_screen: c.POINT = std.mem.zeroes(c.POINT);
var g_press_rect: c.RECT = std.mem.zeroes(c.RECT);
var g_drag_offset: c.POINT = std.mem.zeroes(c.POINT);
var g_was_minimized = false;

var g_window_anim: WindowAnim = .{};
var g_close_countdown: CloseCountdown = .{};
var g_launch_anim: ScalarAnim = .{};
var g_toggle_anim: ScalarAnim = .{};
var g_button_colors = [_]ColorAnim{.{}} ** 5;
var g_toggle_current_color = ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };

const kControlIdleColor = ByteVec4{ .x = 51.0 / 255.0, .y = 51.0 / 255.0, .z = 51.0 / 255.0, .w = 1.0 };
const kControlHoverBlue = ByteVec4{ .x = 100.0 / 255.0, .y = 149.0 / 255.0, .z = 237.0 / 255.0, .w = 1.0 };
const clamp01 = Ui.Clamp01;
const easeOutQuad = Ui.EaseOutQuad;
const easeInOutCubic = Ui.EaseInOutCubic;
const lerpColor = Ui.LerpColor;
const applyOpacity = Ui.ApplyOpacity;
const toU32 = Ui.ColorToU32;
const scaleF = Ui.ScaleF;
const scaleI = Ui.ScaleI;
const scaleIF = Ui.ScaleIF;
const scaleVec2 = Ui.ScaleVec2;
const snapPixel = Ui.SnapPixel;
const snapPixelVec2 = Ui.SnapPixelVec2;

fn makeRectL(x: f32, y: f32, w: f32, h: f32) c.RECT {
    return .{
        .left = @intFromFloat(@floor(x)),
        .top = @intFromFloat(@floor(y)),
        .right = @intFromFloat(@ceil(x + w)),
        .bottom = @intFromFloat(@ceil(y + h)),
    };
}

fn pointInRect(rect: anytype, pt: c.POINT) bool {
    return pt.x >= rect.left and pt.x < rect.right and pt.y >= rect.top and pt.y < rect.bottom;
}

fn lowWordSigned(value: c.LPARAM) i32 {
    const bits: usize = @bitCast(value);
    const lo: u16 = @truncate(bits & 0xFFFF);
    return @as(i16, @bitCast(lo));
}

fn highWordSigned(value: c.LPARAM) i32 {
    const bits: usize = @bitCast(value);
    const hi: u16 = @truncate((bits >> 16) & 0xFFFF);
    return @as(i16, @bitCast(hi));
}

fn lowWordU(value: c.LPARAM) u16 {
    const bits: usize = @bitCast(value);
    return @truncate(bits & 0xFFFF);
}

fn highWordU(value: c.LPARAM) u16 {
    const bits: usize = @bitCast(value);
    return @truncate((bits >> 16) & 0xFFFF);
}

fn wtf8ToWtf16LeZ(wtf8: []const u8, buf: []u16) ![:0]u16 {
    if (buf.len == 0) return error.NoSpaceLeft;
    const len = try std.unicode.wtf8ToWtf16Le(buf[0 .. buf.len - 1], wtf8);
    buf[len] = 0;
    return buf[0..len :0];
}

fn wtf16LeToWtf8Slice(wtf16le: []const u16, out_buf: []u8) ![]const u8 {
    const len = std.unicode.calcWtf8Len(wtf16le);
    if (len > out_buf.len) return error.NoSpaceLeft;
    return out_buf[0..std.unicode.wtf16LeToWtf8(out_buf, wtf16le)];
}

fn computeVersionDisplay(out_buf: []u8) ![]const u8 {
    return strings.computeVersionDisplay(out_buf, VERSION_STR);
}

fn toByteGuiHwnd(hwnd: c.HWND) bgc.HWND {
    return @ptrFromInt(@intFromPtr(hwnd));
}

fn fromByteGuiHwnd(hwnd: ?bgc.HWND) ?c.HWND {
    return if (hwnd) |value| @ptrFromInt(@intFromPtr(value)) else null;
}

fn loadCursorResource(id: u16) ?c.HCURSOR {
    return c.LoadCursorW(null, @ptrFromInt(@as(usize, id)));
}

fn fromByteGuiRect(rect: bgc.RECT) c.RECT {
    return .{
        .left = rect.left,
        .top = rect.top,
        .right = rect.right,
        .bottom = rect.bottom,
    };
}

// CLI Mode
const CLI_CONSOLE_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored CLI");

fn shouldRunCli(args: std.process.Args) bool {
    var args_it = std.process.Args.Iterator.initAllocator(args, allocator) catch return false;
    defer args_it.deinit();

    _ = args_it.next();
    while (args_it.next()) |arg| {
        if (std.ascii.eqlIgnoreCase(arg, "-cli") or
            std.ascii.eqlIgnoreCase(arg, "--cli") or
            std.ascii.eqlIgnoreCase(arg, "/cli"))
        {
            return true;
        }
    }

    return false;
}

fn ensureCliConsole() void {
    _ = c.FreeConsole();
    if (c.AllocConsole() == c.FALSE) return;
    _ = c.SetConsoleTitleW(CLI_CONSOLE_TITLE);
}

fn cliWrite(io: std.Io, message: []const u8) void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    stdout_writer.interface.writeAll(message) catch return;
    stdout_writer.interface.flush() catch {};
}

fn cliPrint(io: std.Io, comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const message = std.fmt.bufPrint(&buf, fmt, args) catch return;
    cliWrite(io, message);
}

fn getProcessPathWtf8(pid: u32, out_buf: []u8) !?[]const u8 {
    if (pid == 0) return null;

    const process = c.OpenProcess(c.PROCESS_QUERY_LIMITED_INFORMATION, c.FALSE, pid) orelse return null;
    defer _ = c.CloseHandle(process);

    var wide_buf: [32768]u16 = undefined;
    var wide_len: c.DWORD = wide_buf.len - 1;
    if (c.QueryFullProcessImageNameW(process, 0, wide_buf[0..].ptr, &wide_len) == c.FALSE or wide_len == 0) return null;

    return try wtf16LeToWtf8Slice(wide_buf[0..wide_len], out_buf);
}

fn runCli() !u8 {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    ensureCliConsole();
    cliPrint(io, "\n[EFU Loader]\n\n", .{});

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch |err| {
        cliPrint(io, "Error: {s}\n", .{loader.describeTempDllError(err)});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    };
    defer {
        loader.deleteTempDll(allocator, temp_dll_path);
        allocator.free(temp_dll_path);
    }

    cliPrint(io, "Ready.\nWaiting for {s}...\n\n", .{loader.target_exe_name});

    var pid: u32 = 0;
    while (pid == 0) {
        pid = loader.findTargetProcess();
        if (pid == 0) c.Sleep(100);
    }

    cliPrint(io, "Process found (PID: {d})\n", .{pid});

    var process_path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    if (try getProcessPathWtf8(pid, &process_path_buf)) |path| {
        cliPrint(io, "Process path: {s}\n", .{path});
    } else {
        cliPrint(io, "Warning: Could not get process path\n", .{});
    }

    c.Sleep(10);

    const injection_succeeded = blk: {
        loader.injectDll(pid, temp_dll_path) catch |err| {
            cliPrint(io, "Injection failed: {s}\n", .{loader.describeInjectError(err)});
            if (loader.injectErrorSuggestsElevation(err)) {
                cliPrint(io, "Try running as administrator.\n", .{});
            }
            cliPrint(io, "\n", .{});
            break :blk false;
        };
        cliPrint(io, "Injection successful.\n\n", .{});
        break :blk true;
    };

    cliPrint(io, "Closing in 5 seconds...\n", .{});
    c.Sleep(5000);
    return if (injection_succeeded) 0 else 1;
}

fn allocOwnedLine(comptime fmt: []const u8, args: anytype) ?[]u8 {
    return std.fmt.allocPrint(allocator, fmt, args) catch null;
}

// Status Output
fn appendStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    appendOwnedStatusLine(line);
}

fn appendWaitingForTargetExeStatus() void {
    appendStatus(strings.status_waiting_for_target_fmt, .{loader.target_exe_name});
}

fn appendOwnedStatusLine(line: []u8) void {
    g_output_lines.append(allocator, line) catch allocator.free(line);
}

fn setLastOwnedStatusLine(line: []u8) void {
    if (g_output_lines.items.len == 0) {
        appendOwnedStatusLine(line);
        return;
    }

    const last_index = g_output_lines.items.len - 1;
    allocator.free(g_output_lines.items[last_index]);
    g_output_lines.items[last_index] = line;
}

fn clearStatusLines() void {
    for (g_output_lines.items) |line| allocator.free(line);
    g_output_lines.deinit(allocator);
    g_output_lines = .empty;
}

fn cancelCloseCountdown() void {
    g_close_countdown = .{};
}

fn makeCountdownStatusLine(action: CloseCountdown.Action, seconds_remaining: i32) ?[]u8 {
    return allocOwnedLine(strings.status_countdown_fmt, .{
        if (action == .minimize) strings.countdown_action_minimize else strings.countdown_action_close,
        seconds_remaining,
        if (seconds_remaining == 1) "" else "s",
    });
}

fn appendCountdownStatus(action: CloseCountdown.Action, seconds_remaining: i32) void {
    const line = makeCountdownStatusLine(action, seconds_remaining) orelse return;
    setLastOwnedStatusLine(line);
}

fn startCountdown(action: CloseCountdown.Action) void {
    g_close_countdown = .{
        .active = true,
        .action = action,
        .remaining_seconds = 5,
        .elapsed = 0.0,
    };
    const line = makeCountdownStatusLine(action, g_close_countdown.remaining_seconds) orelse return;
    appendOwnedStatusLine(line);
}

fn startCloseCountdown() void {
    startCountdown(.close);
}

fn startMinimizeCountdown() void {
    startCountdown(.minimize);
}

// Loader Worker
fn queueLoaderEvent(event: LoaderUiEvent) void {
    g_loader_events_mutex.lock();
    defer g_loader_events_mutex.unlock();
    g_loader_events.append(allocator, event) catch switch (event) {
        .status_line => |line| allocator.free(line),
        .replace_last_status_line => |line| allocator.free(line),
        else => {},
    };
}

fn queueLoaderStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    queueLoaderEvent(.{ .status_line = line });
}

fn queueLoaderReplaceLastStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    queueLoaderEvent(.{ .replace_last_status_line = line });
}

fn drainLoaderEvents() void {
    var pending: std.ArrayListUnmanaged(LoaderUiEvent) = .empty;
    g_loader_events_mutex.lock();
    std.mem.swap(std.ArrayListUnmanaged(LoaderUiEvent), &pending, &g_loader_events);
    g_loader_events_mutex.unlock();
    defer pending.deinit(allocator);

    for (pending.items) |event| {
        switch (event) {
            .clear_status => clearStatusLines(),
            .status_line => |line| appendOwnedStatusLine(line),
            .replace_last_status_line => |line| setLastOwnedStatusLine(line),
            .process_closed => maybeRestoreAfterExit(),
            .minimize_after_inject => {
                g_minimized_by_toggle = true;
                if (g_window_anim.typ == .none) startMinimizeCountdown();
            },
            .close_after_inject => {
                if (g_window_anim.typ == .none) startCloseCountdown();
            },
        }
    }
}

fn clearLoaderEvents() void {
    var pending: std.ArrayListUnmanaged(LoaderUiEvent) = .empty;
    g_loader_events_mutex.lock();
    std.mem.swap(std.ArrayListUnmanaged(LoaderUiEvent), &pending, &g_loader_events);
    g_loader_events_mutex.unlock();
    defer pending.deinit(allocator);

    for (pending.items) |event| {
        switch (event) {
            .status_line => |line| allocator.free(line),
            .replace_last_status_line => |line| allocator.free(line),
            else => {},
        }
    }
}

fn setLoaderMinimizeOnLaunch(enabled: bool) void {
    g_minimize_on_launch = enabled;
    g_loader_control_mutex.lock();
    g_loader_minimize_on_launch = enabled;
    g_loader_control_mutex.unlock();
}

fn loaderMinimizeOnLaunch() bool {
    g_loader_control_mutex.lock();
    defer g_loader_control_mutex.unlock();
    return g_loader_minimize_on_launch;
}

fn ensureWorkerTempDll(state: *LoaderWorkerState) ![]const u8 {
    if (state.temp_dll_path) |path| return path;
    const path = try loader.writeEmbeddedDllToTemp(allocator, embedded_dll);
    state.temp_dll_path = path;
    return path;
}

fn loaderWorkerTick(state: *LoaderWorkerState) void {
    if (state.tracked_pid != 0) {
        if (!loader.isProcessAlive(state.tracked_pid)) {
            state.cleanupTempDll();
            queueLoaderStatus(strings.status_game_process_closed, .{});
            state.tracked_pid = 0;
            state.last_failed_pid = 0;
            queueLoaderEvent(.{ .process_closed = {} });
        }
        return;
    }

    const pid = loader.findTargetProcess();
    if (pid == 0) {
        state.last_failed_pid = 0;
        return;
    }
    if (pid == state.last_failed_pid) return;

    queueLoaderEvent(.{ .clear_status = {} });
    queueLoaderStatus(strings.status_process_found_fmt, .{pid});
    queueLoaderStatus(strings.status_extracting_mod, .{});
    const temp_path = ensureWorkerTempDll(state) catch |err| {
        queueLoaderStatus(strings.status_prepare_temp_dll_failed_fmt, .{loader.describeTempDllError(err)});
        state.last_failed_pid = pid;
        return;
    };

    queueLoaderStatus(strings.status_injecting_mod, .{});
    if (loader.injectDll(pid, temp_path)) |_| {
        queueLoaderReplaceLastStatus(strings.status_injected_success, .{});
        state.tracked_pid = pid;
        state.last_failed_pid = 0;
        if (loaderMinimizeOnLaunch()) {
            queueLoaderEvent(.{ .minimize_after_inject = {} });
        } else {
            queueLoaderEvent(.{ .close_after_inject = {} });
        }
    } else |err| {
        queueLoaderReplaceLastStatus(strings.status_injection_failed_fmt, .{loader.describeInjectError(err)});
        if (loader.injectErrorSuggestsElevation(err)) {
            queueLoaderStatus(strings.status_try_run_admin, .{});
        }
        state.last_failed_pid = pid;
    }
}

fn loaderWorkerMain() void {
    var state = LoaderWorkerState{};
    defer state.deinit();

    while (true) {
        g_loader_control_mutex.lock();
        const should_stop = g_loader_should_stop;
        g_loader_control_mutex.unlock();
        if (should_stop) break;

        loaderWorkerTick(&state);
        c.Sleep(@intCast(PROCESS_POLL_MS));
    }
}

fn startLoaderWorker() bool {
    g_loader_control_mutex.lock();
    g_loader_should_stop = false;
    g_loader_minimize_on_launch = g_minimize_on_launch;
    g_loader_control_mutex.unlock();

    g_loader_thread = std.Thread.spawn(.{}, loaderWorkerMain, .{}) catch return false;
    return true;
}

fn stopLoaderWorker() void {
    if (g_loader_thread) |thread| {
        g_loader_control_mutex.lock();
        g_loader_should_stop = true;
        g_loader_control_mutex.unlock();
        thread.join();
        g_loader_thread = null;
    }
}

// Render Resources
fn makeLogoTextureParams() Ui.SvgTextureBuildParams {
    return .{
        .paths = LOGO_PATH_LAYERS[0..],
        .canvas_pos = .{ .x = LOGO_CANVAS_X, .y = LOGO_CANVAS_Y },
        .canvas_size = .{ .x = LOGO_CANVAS_W, .y = LOGO_CANVAS_H },
        .supersample = LOGO_SUPERSAMPLE,
        .sample_grid = LOGO_SAMPLE_GRID,
        .fill_argb = 0xFF000000,
        .display_mode = .canvas,
    };
}

fn cleanupLogoTexture() void {
    Ui.CleanupTextTexture(&g_logo_texture);
}

fn cleanupButtonLabelTextures() void {
    Ui.CleanupTextTexture(&g_launch_label_texture);
    Ui.CleanupTextTexture(&g_toggle_label_texture);
}

fn rebuildButtonLabelTextures() bool {
    const launch_ok = Ui.BuildTextTexture(&g_launch_label_texture, g_font_launch, 24.0, LABEL_LAUNCH, BUTTON_LABEL_SUPERSAMPLE, 0.9, 1.0);
    const toggle_ok = Ui.BuildTextTexture(&g_toggle_label_texture, g_font_toggle, 20.0, LABEL_MINIMIZE, BUTTON_LABEL_SUPERSAMPLE, 0.45, 1.0);
    return launch_ok and toggle_ok;
}

fn rebuildLogoTexture() bool {
    cleanupLogoTexture();
    return Ui.BuildSvgTexture(&g_logo_texture, makeLogoTextureParams());
}

fn cleanupRenderResources() void {
    cleanupLogoTexture();
    cleanupButtonLabelTextures();
}

fn applyWindowShape() void {
    const hwnd = g_hwnd orelse return;
    // Enable per-pixel alpha compositing via DWM - this allows the OpenGL
    // framebuffer's alpha channel to control window transparency, giving us
    // proper AA on rounded corners without SetWindowRgn clipping.
    const margins = c.MARGINS{ .cxLeftWidth = -1, .cxRightWidth = -1, .cyTopHeight = -1, .cyBottomHeight = -1 };
    _ = c.DwmExtendFrameIntoClientArea(hwnd, &margins);
}

fn applyBaseStyle() void {
    const style = ByteGui.GetStyle();
    style.* = ByteGuiStyle{};
    style.WindowPadding = .{};
    style.FramePadding = .{};
    style.ItemSpacing = .{};
    style.ItemInnerSpacing = .{};
    style.WindowBorderSize = 0.0;
    style.ChildBorderSize = 0.0;
    style.FrameBorderSize = 0.0;
    style.PopupBorderSize = 0.0;
    style.WindowRounding = 0.0;
    style.ChildRounding = 0.0;
    style.FrameRounding = 0.0;
    style.ScrollbarRounding = scaleF(8.0);
    style.ScrollbarSize = scaleF(8.0);
    style.AntiAliasedFill = true;
    style.AntiAliasedLines = true;
    style.CurveTessellationTol = 0.8;
    style.CircleTessellationMaxError = 0.10;

    style.Colors[bytegui.ByteGuiCol_WindowBg] = .{};
    style.Colors[bytegui.ByteGuiCol_ChildBg] = .{};
    style.Colors[bytegui.ByteGuiCol_Text] = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 };
    style.Colors[bytegui.ByteGuiCol_Border] = .{};
    style.Colors[bytegui.ByteGuiCol_ScrollbarBg] = .{};
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrab] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.35 };
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrabHovered] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.55 };
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrabActive] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.75 };
}

fn loadFonts() void {
    const io = ByteGui.GetIO();
    io.Fonts.?.Clear();
    g_font_ui = null;
    g_font_ui_bold = null;
    g_font_console = null;
    g_font_version = null;
    g_font_launch = null;
    g_font_launch_hover = null;
    g_font_launch_peak = null;
    g_font_toggle = null;
    g_font_toggle_hover = null;
    g_font_toggle_peak = null;

    var ui_cfg = ByteFontConfig{};
    ui_cfg.PixelSnapH = true;
    ui_cfg.OversampleH = 1;
    ui_cfg.OversampleV = 1;

    var body_cfg = ByteFontConfig{};
    body_cfg.PixelSnapH = false;
    body_cfg.OversampleH = 1;
    body_cfg.OversampleV = 1;

    g_font_ui = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_regular, "Inter_18pt-Regular.ttf", scaleF(16.0), &ui_cfg);
    g_font_toggle = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_regular, "Inter_18pt-Regular.ttf", scaleF(16.0), &ui_cfg);
    g_font_toggle_hover = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_regular, "Inter_18pt-Regular.ttf", scaleF(17.0), &ui_cfg);
    g_font_toggle_peak = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_regular, "Inter_18pt-Regular.ttf", scaleF(18.0), &ui_cfg);

    g_font_ui_bold = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_semibold, "Inter_18pt-SemiBold.ttf", scaleF(16.0), &ui_cfg);
    g_font_launch = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_semibold, "Inter_18pt-SemiBold.ttf", scaleF(20.0), &ui_cfg);
    g_font_launch_hover = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_semibold, "Inter_18pt-SemiBold.ttf", scaleF(22.0), &ui_cfg);
    g_font_launch_peak = io.Fonts.?.AddFontFromMemoryTTF(embedded_inter_semibold, "Inter_18pt-SemiBold.ttf", scaleF(24.0), &ui_cfg);

    g_font_console = io.Fonts.?.AddFontFromMemoryTTF(embedded_jetbrains_mono, "JetBrainsMono-Regular.ttf", scaleF(13.0), &body_cfg);
    g_font_version = io.Fonts.?.AddFontFromMemoryTTF(embedded_jetbrains_mono, "JetBrainsMono-Regular.ttf", scaleF(12.0), &body_cfg);
}

fn refreshUiScaleResources() void {
    if (ByteGui.GetCurrentContext() == null) return;
    applyBaseStyle();
    loadFonts();
    if (bytegui.ByteGui_ImplOpenGL_HasContext()) {
        _ = rebuildLogoTexture();
        _ = rebuildButtonLabelTextures();
    }
}

// Interaction And Rendering
fn startScalarAnim(anim: *ScalarAnim, target: f32, duration: f32) void {
    if (@abs(anim.value - target) < 0.0001 and !anim.animating) return;
    anim.start = anim.value;
    anim.target = target;
    anim.elapsed = 0.0;
    anim.duration = duration;
    anim.animating = true;
}

fn startButtonColorAnim(id: i32, target: ByteVec4) void {
    if (id < 1 or id > 4) return;
    const anim = &g_button_colors[@intCast(id)];
    anim.start = anim.current;
    anim.target = target;
    anim.elapsed = 0.0;
    anim.duration = 0.12;
    anim.animating = true;
}

fn initLayeredWindowOpacity() bool {
    const hwnd = g_hwnd orelse return false;
    return c.SetLayeredWindowAttributes(hwnd, 0, 255, c.LWA_ALPHA) != c.FALSE;
}

fn setWindowOpacityImmediate(opacity: f32) bool {
    g_window_opacity = clamp01(opacity);
    const hwnd = g_hwnd orelse return false;
    const alpha: c.BYTE = @intFromFloat(@round(g_window_opacity * 255.0));
    return c.SetLayeredWindowAttributes(hwnd, 0, alpha, c.LWA_ALPHA) != c.FALSE;
}

fn activateWindow() void {
    const hwnd = g_hwnd orelse return;
    const fg = c.GetForegroundWindow();
    const our_tid = c.GetCurrentThreadId();
    const fg_tid = if (fg) |w| c.GetWindowThreadProcessId(w, null) else 0;
    if (fg_tid != 0 and fg_tid != our_tid)
        _ = c.AttachThreadInput(our_tid, fg_tid, c.TRUE);
    _ = c.SetWindowPos(hwnd, c.HWND_TOP, 0, 0, 0, 0, c.SWP_NOMOVE | c.SWP_NOSIZE);
    _ = c.SetForegroundWindow(hwnd);
    if (fg_tid != 0 and fg_tid != our_tid)
        _ = c.AttachThreadInput(our_tid, fg_tid, c.FALSE);
}

fn startWindowAnimation(typ: WindowAnimType) void {
    const hwnd = g_hwnd orelse return;
    var rc = std.mem.zeroes(c.RECT);
    _ = c.GetWindowRect(hwnd, &rc);

    cancelCloseCountdown();
    g_window_anim = .{ .typ = typ };
    switch (typ) {
        .slide_in => {
            g_window_anim.duration = WINDOW_SLIDE_IN_DURATION;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top + scaleIF(WINDOW_SLIDE_IN_OFFSET) };
            g_window_anim.end_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.start_opacity = 0.0;
            g_window_anim.end_opacity = 1.0;
            _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, g_window_anim.start_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            _ = setWindowOpacityImmediate(0.0);
        },
        .slide_out_close => {
            g_window_anim.duration = WINDOW_SLIDE_OUT_DURATION;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = .{ .x = rc.left, .y = rc.top + scaleIF(WINDOW_SLIDE_OUT_OFFSET) };
            g_window_anim.start_opacity = 1.0;
            g_window_anim.end_opacity = 0.0;
        },
        .fade_out_minimize => {
            g_window_anim.duration = 0.200;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = g_window_anim.start_pos;
        },
        .fade_in_restore => {
            g_window_anim.duration = 0.300;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = g_window_anim.start_pos;
            _ = setWindowOpacityImmediate(0.0);
        },
        .none => {},
    }
}

fn updateAnimations(dt: f32) void {
    var i: usize = 1;
    while (i <= 4) : (i += 1) {
        const anim = &g_button_colors[i];
        if (!anim.animating) continue;
        anim.elapsed += dt;
        const t = if (anim.duration > 0.0) anim.elapsed / anim.duration else 1.0;
        if (t >= 1.0) {
            anim.current = anim.target;
            anim.animating = false;
        } else {
            anim.current = lerpColor(anim.start, anim.target, easeOutQuad(t));
        }
    }

    for (&[_]*ScalarAnim{ &g_launch_anim, &g_toggle_anim }) |anim| {
        if (!anim.animating) continue;
        anim.elapsed += dt;
        const t = if (anim.duration > 0.0) anim.elapsed / anim.duration else 1.0;
        if (t >= 1.0) {
            anim.value = anim.target;
            anim.animating = false;
        } else {
            anim.value = anim.start + (anim.target - anim.start) * easeOutQuad(t);
        }
    }

    const toggle_target = if (g_minimize_on_launch)
        ByteVec4{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }
    else
        ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };
    g_toggle_current_color = lerpColor(g_toggle_current_color, toggle_target, clamp01(dt * 12.0));

    if (g_close_countdown.active and g_window_anim.typ == .none) {
        g_close_countdown.elapsed += dt;
        while (g_close_countdown.active and g_close_countdown.elapsed >= 1.0) {
            g_close_countdown.elapsed -= 1.0;
            g_close_countdown.remaining_seconds -= 1;
            if (g_close_countdown.remaining_seconds > 0) {
                appendCountdownStatus(g_close_countdown.action, g_close_countdown.remaining_seconds);
            } else {
                const action = g_close_countdown.action;
                cancelCloseCountdown();
                if (g_window_anim.typ == .none) {
                    switch (action) {
                        .close => startWindowAnimation(.slide_out_close),
                        .minimize => startWindowAnimation(.fade_out_minimize),
                    }
                }
            }
        }
    }

    const hwnd = g_hwnd orelse return;
    switch (g_window_anim.typ) {
        .none => {},
        .slide_in => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                _ = setWindowOpacityImmediate(1.0);
                _ = c.SetWindowPos(hwnd, null, g_window_anim.end_pos.x, g_window_anim.end_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
                g_window_anim.typ = .none;
                activateWindow();
            } else {
                const move_t = easeInOutCubic(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                _ = setWindowOpacityImmediate(easeOutQuad(t));
                _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            }
        },
        .slide_out_close => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                _ = setWindowOpacityImmediate(0.0);
                _ = c.SetWindowPos(hwnd, null, g_window_anim.end_pos.x, g_window_anim.end_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
                _ = c.DestroyWindow(hwnd);
                g_window_anim.typ = .none;
            } else {
                const move_t = easeInOutCubic(t);
                const fade_t = easeOutQuad(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                _ = setWindowOpacityImmediate(1.0 - fade_t);
                _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            }
        },
        .fade_out_minimize => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                _ = setWindowOpacityImmediate(0.0);
                g_window_anim.typ = .none;
                if (g_minimized_by_toggle) {
                    const line = allocOwnedLine(strings.status_minimized, .{});
                    if (line) |owned_line| setLastOwnedStatusLine(owned_line);
                }
                _ = c.ShowWindow(hwnd, c.SW_MINIMIZE);
            } else {
                _ = setWindowOpacityImmediate(1.0 - t);
            }
        },
        .fade_in_restore => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                _ = setWindowOpacityImmediate(1.0);
                g_window_anim.typ = .none;
            } else {
                _ = setWindowOpacityImmediate(t);
            }
        },
    }
}

fn pointInRoundedRectClient(pt: c.POINT) bool {
    return Ui.PointInCornerOnlyRoundedRect(
        .{ .x = pt.x, .y = pt.y },
        .{},
        .{
            .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()),
            .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()),
        },
        @floatFromInt(scaleI(CORNER_RADIUS)),
    );
}

fn getVersionRect() bgc.RECT {
    const font = if (g_font_version != null) g_font_version else g_font_console;
    const pos = snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y));
    return ByteGui.CalcTextHitRect(font, scaleF(12.0), pos, g_version_display, scaleF(3.0), null, 0.0);
}

fn getInfoRect() c.RECT {
    const hit_padding = scaleF(4.0);
    var rect = makeRectL(scaleF(INFO_X) - hit_padding, scaleF(INFO_Y) - hit_padding, scaleF(INFO_W) + hit_padding * 2.0, scaleF(INFO_H) + hit_padding * 2.0);
    rect.left = 0;
    rect.top = 0;
    return rect;
}

fn getLaunchRect(expanded_hit: bool) c.RECT {
    const anim = g_launch_anim.value;
    const expand_w = (if (expanded_hit) scaleF(24.0) else scaleF(12.0)) * anim;
    const expand_h = (if (expanded_hit) scaleF(8.0) else scaleF(4.0)) * anim;
    const w = scaleF(LAUNCH_W) + expand_w;
    const h = scaleF(LAUNCH_H) + expand_h;
    const cx = scaleF(LAUNCH_X + LAUNCH_W * 0.5);
    const cy = scaleF(LAUNCH_Y + LAUNCH_H * 0.5);
    return makeRectL(cx - w * 0.5, cy - h * 0.5, w, h);
}

fn getToggleRect(expanded_hit: bool) c.RECT {
    _ = expanded_hit;
    const anim = g_toggle_anim.value;
    const expand_w = scaleF(12.0) * anim;
    const expand_h = scaleF(3.0) * anim;
    const w = scaleF(TOGGLE_W) + expand_w;
    const h = scaleF(TOGGLE_H) + expand_h;
    const cx = scaleF(TOGGLE_X + TOGGLE_W * 0.5);
    const cy = scaleF(TOGGLE_Y + TOGGLE_H * 0.5 + TOGGLE_Y_OFFSET);
    return makeRectL(cx - w * 0.5, cy - h * 0.5, w, h);
}

fn getWindowControlHitRects(min_hit: *bgc.RECT, close_hit: *bgc.RECT) void {
    ByteGui.CalcHorizontalNeighborHitRects(
        scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET),
        scaleVec2(MIN_W, MIN_H),
        scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET),
        scaleVec2(CLOSE_W, CLOSE_H),
        .{ .x = scaleF(4.0), .y = 0.0, .z = 0.0, .w = 0.0 },
        min_hit,
        close_hit,
    );

    const min_visual_left = scaleF(MIN_X);
    const min_visual_right = scaleF(MIN_X + MIN_W);
    const min_right_extra = @as(f32, @floatFromInt(min_hit.right)) - min_visual_right;
    min_hit.left = @intFromFloat(@floor(min_visual_left - min_right_extra));
    min_hit.top = 0;

    close_hit.top = 0;
    close_hit.right = bytegui.ByteGui_ImplWin32_GetWindowWidth();
}

fn hitTestButton(pt: c.POINT) i32 {
    var close_hit = std.mem.zeroes(bgc.RECT);
    var min_hit = std.mem.zeroes(bgc.RECT);
    getWindowControlHitRects(&min_hit, &close_hit);

    const info_hit = getInfoRect();
    const version_hit = getVersionRect();
    const launch_hit = getLaunchRect(false);
    const toggle_hit = getToggleRect(true);

    if (pointInRect(toggle_hit, pt)) return 6;
    if (pointInRect(close_hit, pt)) return 1;
    if (pointInRect(min_hit, pt)) return 2;
    if (pointInRect(info_hit, pt)) return 3;
    if (pointInRect(version_hit, pt)) return 4;
    if (pointInRect(launch_hit, pt) and g_launch_btn_enabled) return 5;
    return 0;
}

fn updateHoverStates(dt: f32) void {
    _ = dt;
    const hwnd = g_hwnd orelse return;
    var pt = std.mem.zeroes(c.POINT);
    _ = c.GetCursorPos(&pt);
    _ = c.ScreenToClient(hwnd, &pt);

    const prev_hover = g_hovered_button;
    g_hovered_button = if (!pointInRoundedRectClient(pt)) 0 else hitTestButton(pt);
    if (g_hovered_button != prev_hover) {
        if (prev_hover >= 1 and prev_hover <= 4) startButtonColorAnim(prev_hover, kControlIdleColor);
        if (g_hovered_button == 1) {
            startButtonColorAnim(1, .{ .x = 1.0, .y = 127.0 / 255.0, .z = 80.0 / 255.0, .w = 1.0 });
        } else if (g_hovered_button == 2) {
            startButtonColorAnim(2, .{ .x = 218.0 / 255.0, .y = 165.0 / 255.0, .z = 32.0 / 255.0, .w = 1.0 });
        } else if (g_hovered_button == 3 or g_hovered_button == 4) {
            startButtonColorAnim(g_hovered_button, kControlHoverBlue);
        }

        startScalarAnim(&g_launch_anim, if (g_hovered_button == 5) 1.0 else 0.0, 0.18);
        startScalarAnim(&g_toggle_anim, if (g_hovered_button == 6) 1.0 else 0.0, 0.18);
    }

    _ = c.SetCursor(loadCursorResource(if (g_hovered_button == 5 or g_hovered_button == 6) IDC_HAND_ID else IDC_ARROW_ID));
}

fn drawYellowRotatedRect(draw: ?*ByteDrawList, opacity: f32) void {
    const rect_left = scaleF(-95.0);
    const rect_top = scaleF(1.0);
    const rect_width = scaleF(403.0);
    const rect_height = scaleF(194.0);
    const pivot_x = rect_left + rect_width * 0.3;
    const pivot_y = rect_top + rect_height * 0.5;
    const color = toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, opacity));
    Ui.DrawRotatedRectClippedToCornerOnlyRoundedRect(
        draw,
        .{ .x = rect_left, .y = rect_top },
        .{ .x = rect_width, .y = rect_height },
        .{ .x = pivot_x, .y = pivot_y },
        -45.0 * std.math.pi / 180.0,
        .{ .x = 0.0, .y = 0.0 },
        .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) },
        snapPixel(scaleF(CORNER_RADIUS)),
        color,
        std.math.clamp(scaleIF(6.0), 6, 20),
    );
}

fn getButtonLabelTexture(is_launch: bool) *const TextTexture {
    return if (is_launch) &g_launch_label_texture else &g_toggle_label_texture;
}

fn drawAnimatedButtonLabelTexture(draw: ?*ByteDrawList, is_launch: bool, pos: ByteVec2, size: ByteVec2, anim: f32, opacity: f32) bool {
    const text_texture = getButtonLabelTexture(is_launch);
    return Ui.DrawAnimatedTextureCentered(
        draw,
        text_texture,
        pos,
        size,
        .{ .x = scaleF(if (is_launch) 6.0 else 1.0), .y = scaleF(if (is_launch) 4.0 else 0.25) },
        if (is_launch) 0.94 else 0.92,
        if (is_launch) 0.98 else 0.94,
        anim,
        opacity,
    );
}

fn drawAnimatedBoxButtonVisual(id: []const u8, _: []const u8, base_pos: ByteVec2, base_size: ByteVec2, anim: f32, enabled: bool, base_color: ByteVec4, opacity: f32) void {
    const is_launch = std.mem.eql(u8, id, "launch_btn");
    const center = ByteVec2{ .x = base_pos.x + base_size.x * 0.5, .y = base_pos.y + base_size.y * 0.5 };
    const size = ByteVec2{ .x = base_size.x + scaleF(12.0) * anim, .y = base_size.y + (if (is_launch) scaleF(4.0) else scaleF(3.0)) * anim };
    const pos = ByteVec2{ .x = center.x - size.x * 0.5, .y = center.y - size.y * 0.5 };
    const color = if (enabled) base_color else ByteVec4{ .x = 180.0 / 255.0, .y = 180.0 / 255.0, .z = 180.0 / 255.0, .w = 1.0 };
    const rounding = if (is_launch) scaleF(8.0) + scaleF(4.0) * anim else scaleF(5.0) + scaleF(2.0) * anim;

    const draw = ByteGui.GetWindowDrawList() orelse return;
    const saved_flags = draw.Flags;
    draw.Flags |= bytegui.ByteDrawListFlags_AntiAliasedFill;
    draw.AddRectFilled(pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, toU32(applyOpacity(color, opacity)), rounding);
    draw.Flags = saved_flags;
    _ = drawAnimatedButtonLabelTexture(draw, is_launch, pos, size, anim, opacity);
}

fn drawLogoVisual(draw: ?*ByteDrawList, opacity: f32) void {
    const active_draw = draw orelse return;
    const texture = g_logo_texture.texture orelse return;
    const pos = snapPixelVec2(scaleVec2(LOGO_CANVAS_X, LOGO_CANVAS_Y));
    const size = snapPixelVec2(g_logo_texture.display_size_px);
    active_draw.AddImage(
        texture,
        pos,
        .{ .x = pos.x + size.x, .y = pos.y + size.y },
        g_logo_texture.uv_min,
        g_logo_texture.uv_max,
        toU32(applyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, opacity)),
    );
}

fn drawUI() void {
    const render_opacity: f32 = 1.0;
    ByteGui.SetNextWindowPos(.{});
    ByteGui.SetNextWindowSize(.{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) });

    const flags: u32 = ByteGuiWindowFlags_NoDecoration | ByteGuiWindowFlags_NoMove | ByteGuiWindowFlags_NoResize | ByteGuiWindowFlags_NoSavedSettings | ByteGuiWindowFlags_NoNav | ByteGuiWindowFlags_NoBackground;
    _ = ByteGui.Begin("##root", null, flags);

    const draw = ByteGui.GetWindowDrawList() orelse return;
    ByteGui.DrawCornerOnlyRoundedRectFilled(draw, .{}, .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) }, snapPixel(scaleF(CORNER_RADIUS)), toU32(applyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(6.0), 6, 20));
    drawYellowRotatedRect(draw, render_opacity);

    ByteGui.DrawInfoGlyph(draw, scaleVec2(INFO_X, INFO_Y), scaleVec2(INFO_W, INFO_H), toU32(applyOpacity(g_button_colors[3].current, render_opacity)), toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(72.0), 72, 160));
    ByteGui.DrawWindowControlGlyph(draw, scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET), scaleVec2(MIN_W, MIN_H), toU32(applyOpacity(g_button_colors[2].current, render_opacity)), false);
    ByteGui.DrawWindowControlGlyph(draw, scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET), scaleVec2(CLOSE_W, CLOSE_H), toU32(applyOpacity(g_button_colors[1].current, render_opacity)), true);
    drawLogoVisual(draw, render_opacity);

    const output_inset = scaleF(1.0);
    const output_pos = scaleVec2(OUTPUT_X, OUTPUT_Y);
    const output_size = scaleVec2(OUTPUT_W, OUTPUT_H);
    ByteGui.SetCursorScreenPos(.{ .x = output_pos.x + output_inset, .y = output_pos.y + output_inset });
    _ = ByteGui.BeginChild("##output", .{
        .x = @max(1.0, output_size.x - output_inset * 2.0),
        .y = @max(1.0, output_size.y - output_inset * 2.0),
    }, false, ByteGuiWindowFlags_NoBackground | ByteGuiWindowFlags_NoScrollbar | ByteGuiWindowFlags_NoScrollWithMouse);
    ByteGui.PushStyleVar(ByteGuiStyleVar_Alpha, render_opacity);
    ByteGui.PushFont(g_font_console);
    for (g_output_lines.items) |line| ByteGui.TextWrapped("{s}", .{line});
    ByteGui.PopFont();
    ByteGui.PopStyleVar(1);
    ByteGui.EndChild();

    draw.AddText(g_font_version, scaleF(12.0), snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y)), toU32(applyOpacity(g_button_colors[4].current, render_opacity)), g_version_display, null);
    drawAnimatedBoxButtonVisual("toggle_btn", "Minimize on Launch", scaleVec2(TOGGLE_X, TOGGLE_Y + TOGGLE_Y_OFFSET), scaleVec2(TOGGLE_W, TOGGLE_H), g_toggle_anim.value, true, g_toggle_current_color, render_opacity);
    drawAnimatedBoxButtonVisual("launch_btn", "Launch Game", scaleVec2(LAUNCH_X, LAUNCH_Y), scaleVec2(LAUNCH_W, LAUNCH_H), g_launch_anim.value, g_launch_btn_enabled, .{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, render_opacity);

    ByteGui.End();
}

fn refreshGamePathStatus() void {
    if (g_game_exe_path) |path| allocator.free(path);
    g_game_exe_path = loader.detectGameExe(g_environ, allocator) catch null;
    g_launch_btn_enabled = g_game_exe_path != null;
}

fn maybeRestoreAfterExit() void {
    if (!g_minimized_by_toggle or g_hwnd == null) return;
    if (c.IsIconic(g_hwnd.?) == c.FALSE) return;
    cancelCloseCountdown();
    clearStatusLines();
    _ = c.ShowWindow(g_hwnd.?, c.SW_RESTORE);
    activateWindow();
    appendStatus(strings.status_ready_for_injection_again, .{});
    appendWaitingForTargetExeStatus();
    g_minimized_by_toggle = false;
}

fn launchGameAction() void {
    cancelCloseCountdown();
    if (!g_launch_btn_enabled or g_game_exe_path == null) {
        appendStatus(strings.status_launch_requested_unavailable, .{});
        return;
    }
    loader.launchGame(g_game_exe_path.?) catch |err| {
        appendStatus(strings.status_launch_failed_fmt, .{loader.describeLaunchError(err)});
        return;
    };
    appendStatus(strings.status_launching_game, .{});
}

fn openReadme() void {
    _ = c.ShellExecuteW(null, std.unicode.utf8ToUtf16LeStringLiteral("open"), README_URL, null, null, c.SW_SHOWNORMAL);
}

fn openReleaseTag() void {
    var version_buf: [32]u8 = undefined;
    const normalized = if (VERSION_STR.len > 0 and (VERSION_STR[0] == 'v' or VERSION_STR[0] == 'V'))
        VERSION_STR
    else
        std.fmt.bufPrint(&version_buf, "v{s}", .{VERSION_STR}) catch return;

    var url_utf8_buf: [160]u8 = undefined;
    const url_utf8 = std.fmt.bufPrint(
        &url_utf8_buf,
        "https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/{s}",
        .{normalized},
    ) catch return;

    var url_utf16_buf: [160]u16 = undefined;
    const url_utf16 = wtf8ToWtf16LeZ(url_utf8, &url_utf16_buf) catch return;
    _ = c.ShellExecuteW(null, std.unicode.utf8ToUtf16LeStringLiteral("open"), url_utf16.ptr, null, null, c.SW_SHOWNORMAL);
}

// App Lifetime
fn onButtonActivated(id: i32) void {
    switch (id) {
        1 => if (g_window_anim.typ == .none) startWindowAnimation(.slide_out_close),
        2 => if (g_window_anim.typ == .none) startWindowAnimation(.fade_out_minimize),
        3 => openReadme(),
        4 => openReleaseTag(),
        5 => launchGameAction(),
        6 => setLoaderMinimizeOnLaunch(!g_minimize_on_launch),
        else => {},
    }
}

fn handleLButtonDown(hwnd: c.HWND, l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    if (!pointInRoundedRectClient(pt)) return 0;

    const hit_id = hitTestButton(pt);
    if (hit_id != 0) {
        g_pressed_button = hit_id;
        g_press_captured = true;
        g_press_canceled = false;
        _ = c.GetCursorPos(&g_press_screen);

        var close_hit = std.mem.zeroes(bgc.RECT);
        var min_hit = std.mem.zeroes(bgc.RECT);
        getWindowControlHitRects(&min_hit, &close_hit);

        g_press_rect = switch (hit_id) {
            1 => fromByteGuiRect(close_hit),
            2 => fromByteGuiRect(min_hit),
            3 => getInfoRect(),
            4 => fromByteGuiRect(getVersionRect()),
            5 => getLaunchRect(false),
            6 => getToggleRect(true),
            else => std.mem.zeroes(c.RECT),
        };

        _ = c.SetCapture(hwnd);
        return 0;
    }

    g_dragging = true;
    g_drag_offset = .{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    _ = c.SetCapture(hwnd);
    return 0;
}

fn handleMouseMove(hwnd: c.HWND) c.LRESULT {
    if (g_dragging) {
        var cur = std.mem.zeroes(c.POINT);
        _ = c.GetCursorPos(&cur);
        _ = c.SetWindowPos(hwnd, null, cur.x - g_drag_offset.x, cur.y - g_drag_offset.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
        return 0;
    }

    if (g_press_captured) {
        var cur = std.mem.zeroes(c.POINT);
        _ = c.GetCursorPos(&cur);
        const dx = @abs(cur.x - g_press_screen.x);
        const dy = @abs(cur.y - g_press_screen.y);
        if (dx >= scaleI(DRAG_THRESHOLD) or dy >= scaleI(DRAG_THRESHOLD)) g_press_canceled = true;
        return 0;
    }
    return -1;
}

fn handleLButtonUp(l_param: c.LPARAM) c.LRESULT {
    if (g_dragging) {
        g_dragging = false;
        _ = c.ReleaseCapture();
        return 0;
    }

    if (g_press_captured) {
        _ = c.ReleaseCapture();
        const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
        if (!g_press_canceled and c.PtInRect(&g_press_rect, pt) != c.FALSE) onButtonActivated(g_pressed_button);
        g_pressed_button = 0;
        g_press_captured = false;
        g_press_canceled = false;
        return 0;
    }
    return -1;
}

fn wndProc(hwnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.winapi) c.LRESULT {
    const active_hwnd = hwnd;
    setGuiTraceFmt("wnd:msg={x}", .{msg});

    if (msg == c.WM_NCHITTEST) {
        var pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
        _ = c.ScreenToClient(active_hwnd, &pt);
        if (!pointInRoundedRectClient(pt)) return c.HTTRANSPARENT;
        return c.HTCLIENT;
    }

    switch (msg) {
        c.WM_SETCURSOR => {
            if (lowWordU(l_param) == 1) {
                _ = c.SetCursor(loadCursorResource(if (g_hovered_button == 5 or g_hovered_button == 6) IDC_HAND_ID else IDC_ARROW_ID));
                return 1;
            }
        },
        c.WM_LBUTTONDOWN => return handleLButtonDown(active_hwnd, l_param),
        c.WM_MOUSEMOVE => {
            const result = handleMouseMove(active_hwnd);
            if (result != -1) return result;
        },
        c.WM_LBUTTONUP => {
            const result = handleLButtonUp(l_param);
            if (result != -1) return result;
        },
        c.WM_SIZE => {
            if (w_param == c.SIZE_MINIMIZED) {
                g_was_minimized = true;
            } else {
                const width = lowWordU(l_param);
                const height = highWordU(l_param);
                if (width > 0 and height > 0) {
                    bytegui.ByteGui_ImplOpenGL_Resize(width, height);
                    applyWindowShape();
                }
                if (w_param == c.SIZE_RESTORED and g_was_minimized) {
                    g_was_minimized = false;
                    startWindowAnimation(.fade_in_restore);
                }
            }
            return 0;
        },
        c.WM_DPICHANGED => {
            const old_scale = bytegui.ByteGui_ImplWin32_GetDpiScale();
            if (bytegui.ByteGui_ImplWin32_HandleDpiChanged(w_param, l_param, true)) {
                refreshUiScaleResources();
                applyWindowShape();
                if (g_dragging) {
                    const new_scale = bytegui.ByteGui_ImplWin32_GetDpiScale();
                    g_drag_offset.x = @intFromFloat(@ceil(@as(f32, @floatFromInt(g_drag_offset.x)) * (new_scale / old_scale)));
                    g_drag_offset.y = @intFromFloat(@ceil(@as(f32, @floatFromInt(g_drag_offset.y)) * (new_scale / old_scale)));
                }
            }
            return 0;
        },
        c.WM_ERASEBKGND => return 1,
        c.WM_DESTROY => {
            if (g_hwnd != null and g_hwnd.? == active_hwnd) g_hwnd = null;
            g_running = false;
            c.PostQuitMessage(0);
            return 0;
        },
        else => {},
    }

    _ = bytegui.ByteGui_ImplWin32_WndProcHandler(toByteGuiHwnd(active_hwnd), msg, w_param, l_param);
    return c.DefWindowProcW(active_hwnd, msg, w_param, l_param);
}

fn wndProcBridge(hwnd: bgc.HWND, msg: bgc.UINT, w_param: bgc.WPARAM, l_param: bgc.LPARAM) callconv(.winapi) bgc.LRESULT {
    return wndProc(@ptrFromInt(@intFromPtr(hwnd)), msg, w_param, l_param);
}

noinline fn initGuiApp(instance: ?c.HMODULE) bool {
    setGuiTrace("init:start");
    bytegui.BYTEGUI_CHECKVERSION();
    _ = ByteGui.CreateContext() orelse {
        setGuiTrace("init:create_context_failed");
        return false;
    };
    setGuiTrace("init:context_ok");

    var window_config = ByteGuiPlatformWindowConfig{};
    setGuiTrace("init:config_0");
    window_config.Instance = if (instance) |handle| @ptrFromInt(@intFromPtr(handle)) else null;
    setGuiTrace("init:config_1");
    window_config.WndProc = wndProcBridge;
    setGuiTrace("init:config_2");
    window_config.ClassName = WINDOW_CLASS;
    setGuiTrace("init:config_3");
    window_config.Title = APP_TITLE;
    setGuiTrace("init:config_4");
    window_config.ExStyle |= c.WS_EX_LAYERED;
    window_config.IconResourceId = APP_ICON_RESOURCE_ID;
    window_config.LogicalWidth = WINDOW_WIDTH;
    window_config.LogicalHeight = WINDOW_HEIGHT;
    setGuiTrace("init:config_5");
    std.mem.doNotOptimizeAway(window_config);
    setGuiTrace("init:config_6");

    if (!bytegui.ByteGui_ImplWin32_CreatePlatformWindow(&window_config)) {
        setGuiTrace("init:create_window_failed");
        return false;
    }
    const platform_hwnd = bytegui.ByteGui_ImplWin32_GetPlatformHwnd();
    g_hwnd = fromByteGuiHwnd(platform_hwnd);
    if (!initLayeredWindowOpacity()) {
        setGuiTrace("init:layered_alpha_failed");
        return false;
    }
    setGuiTrace("init:window_ok");
    if (!bytegui.ByteGui_ImplOpenGL_Init(platform_hwnd, @intCast(bytegui.ByteGui_ImplWin32_GetWindowWidth()), @intCast(bytegui.ByteGui_ImplWin32_GetWindowHeight()))) {
        setGuiTrace("init:opengl_failed");
        return false;
    }
    setGuiTrace("init:opengl_ok");

    const io = ByteGui.GetIO();
    io.IniFilename = null;
    io.LogFilename = null;
    io.DisplaySize = .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) };

    applyBaseStyle();
    loadFonts();
    setGuiTrace("init:fonts_ok");
    _ = bytegui.ByteGui_ImplWin32_Init(platform_hwnd);
    _ = rebuildLogoTexture();
    _ = rebuildButtonLabelTextures();
    refreshGamePathStatus();

    if (g_launch_btn_enabled) {
        appendStatus(strings.status_game_found, .{});
        appendStatus(strings.status_launch_here_or_external, .{});
        appendWaitingForTargetExeStatus();
    } else {
        appendStatus(strings.status_game_not_found, .{});
        appendStatus(strings.status_launch_externally, .{});
    }
    if (!startLoaderWorker()) {
        appendStatus(strings.status_monitor_failed, .{});
    }

    for (g_button_colors[1..5]) |*color_anim| {
        color_anim.current = kControlIdleColor;
        color_anim.start = kControlIdleColor;
        color_anim.target = kControlIdleColor;
    }

    applyWindowShape();
    _ = setWindowOpacityImmediate(0.0);
    _ = c.ShowWindow(g_hwnd.?, c.SW_SHOW);
    activateWindow();
    _ = c.UpdateWindow(g_hwnd.?);
    startWindowAnimation(.slide_in);
    setGuiTrace("init:done");
    return true;
}

fn shutdownGuiApp() void {
    stopLoaderWorker();
    clearLoaderEvents();
    bytegui.ByteGui_ImplOpenGL_Shutdown();
    bytegui.ByteGui_ImplWin32_Shutdown();
    cleanupRenderResources();
    if (g_hwnd != null) bytegui.ByteGui_ImplWin32_DestroyPlatformWindow();
    if (ByteGui.GetCurrentContext() != null) ByteGui.DestroyContext(null);
    if (g_game_exe_path) |path| allocator.free(path);
    clearStatusLines();
}

fn runGui() !u8 {
    g_version_display = try computeVersionDisplay(&g_version_display_buf);
    if (!initGuiApp(c.GetModuleHandleW(null))) {
        shutdownGuiApp();
        return 1;
    }
    defer shutdownGuiApp();

    var msg = std.mem.zeroes(c.MSG);
    while (g_running) {
        while (c.PeekMessageW(&msg, null, 0, 0, c.PM_REMOVE) != c.FALSE) {
            _ = c.TranslateMessage(&msg);
            _ = c.DispatchMessageW(&msg);
            if (msg.message == c.WM_QUIT) g_running = false;
        }
        if (!g_running) break;

        const io = ByteGui.GetIO();
        const dt = @min(if (io.DeltaTime > 0.0) io.DeltaTime else 1.0 / 60.0, 1.0 / 30.0);
        drainLoaderEvents();
        updateHoverStates(dt);
        updateAnimations(dt);
        if (!g_running or g_hwnd == null) break;

        bytegui.ByteGui_ImplOpenGL_NewFrame();
        bytegui.ByteGui_ImplWin32_NewFrame();
        ByteGui.NewFrame();
        drawUI();
        ByteGui.Render();

        const clear_color = [4]f32{ 0, 0, 0, 0 };
        setGuiTrace("frame:begin");
        _ = bytegui.ByteGui_ImplOpenGL_BeginFrame(&clear_color);
        setGuiTrace("frame:render");
        bytegui.ByteGui_ImplOpenGL_RenderDrawData(ByteGui.GetDrawData());
        setGuiTrace("frame:present");
        _ = bytegui.ByteGui_ImplOpenGL_Present();
        setGuiTrace("frame:done");
        c.Sleep(1);
    }
    return 0;
}

pub fn main(init: std.process.Init.Minimal) void {
    g_environ = init.environ;
    const code = if (shouldRunCli(init.args))
        runCli() catch 1
    else blk: {
        break :blk runGui() catch 1;
    };
    std.process.exit(code);
}
