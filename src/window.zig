// GUI launcher
const std = @import("std");

const bytegui = @import("bytegui.zig");
const cli = @import("cli.zig");
const loader = @import("loader.zig");
const app_version = @import("version");
const strings = @import("strings.zig");
pub const c = @import("win32.zig");

const allocator = std.heap.c_allocator;

const ByteGui = bytegui.ByteGui;
const ByteGuiStyle = bytegui.ByteGuiStyle;
const ByteGuiWindowFlags_NoBackground = bytegui.ByteGuiWindowFlags_NoBackground;
const ByteGuiWindowFlags_NoDecoration = bytegui.ByteGuiWindowFlags_NoDecoration;
const ByteGuiWindowFlags_NoMove = bytegui.ByteGuiWindowFlags_NoMove;
const ByteGuiWindowFlags_NoNav = bytegui.ByteGuiWindowFlags_NoNav;
const ByteGuiWindowFlags_NoResize = bytegui.ByteGuiWindowFlags_NoResize;
const ByteGuiWindowFlags_NoSavedSettings = bytegui.ByteGuiWindowFlags_NoSavedSettings;
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
const embedded_toggle_font = @embedFile("toggle-label.ttf");
const embedded_launch_font = @embedFile("launch-button.ttf");
const embedded_version_font = @embedFile("version-info.ttf");
const embedded_textbox_font = @embedFile("text-box.ttf");

// Layout and embedded assets
const VERSION_STR = app_version.version_str;
const APP_TITLE = std.unicode.utf8ToUtf16LeStringLiteral(strings.app_title);
const WINDOW_CLASS = std.unicode.utf8ToUtf16LeStringLiteral("EndfieldUncensoredGL");
const README_URL = std.unicode.utf8ToUtf16LeStringLiteral("https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md");
const RELEASE_URL_FMT = "https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/{s}";
const SHELL_OPEN_OPERATION = std.unicode.utf8ToUtf16LeStringLiteral("open");
const LABEL_LAUNCH = strings.label_launch;
const LABEL_MINIMIZE = strings.label_minimize;
const LABEL_STAY_OPEN = strings.label_stay_open;
const LABEL_EFMI = strings.label_efmi;
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

const MAIN_CONTENT_SIZE = 90.0;
const MAIN_CONTENT_CENTER_EDGE_OFFSET = MAIN_CONTENT_SIZE * 0.10;
const OUTPUT_W = MAIN_CONTENT_SIZE * 2.48;
const OUTPUT_SCROLLBAR_W = 4.0;
const OUTPUT_SCROLLBAR_PAD = 2.0;
const OUTPUT_SCROLLBAR_MIN_H = 18.0;
const OUTPUT_WHEEL_LINES = 3.0;

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

const EFMI_X = 313.0;
const EFMI_Y = LAUNCH_Y;
const EFMI_W = 42.0;
const EFMI_H = LAUNCH_H;
const EFMI_VISUAL_X_OFFSET = 4.0;
const EFMI_VISIBLE_W = 28.0;
const EFMI_UNDERLAP_W = 40.0;
const EFMI_SHADOW_DARKEN = 0.86;
const EFMI_SHADOW_WIDTH = 8.0;
const EFMI_SHADOW_STRENGTH = 0.42;
const EFMI_LABEL_LINE_SIZE = 14.0;

const DRAG_THRESHOLD = 12;
const PROCESS_POLL_MS: u64 = 175;
const LAUNCH_COOLDOWN_MS: u64 = 3_000;
const EFMI_LAUNCH_COOLDOWN_MS: u64 = 10_000;
const BUTTON_LABEL_HOVER_DELTA = 0.02;
const BUTTON_LABEL_SUPERSAMPLE = 1.0;
const BUTTON_LABEL_RENDER_SCALE = 1.25;
const IDC_ARROW_ID: u16 = 32512;
const IDC_IBEAM_ID: u16 = 32513;
const IDC_HAND_ID: u16 = 32649;
const WHEEL_DELTA = 120;
const embedded_dll = @embedFile("EFUHook");
const LOGO_EF_PATH = "M3.37,13.25h7.9V9.68H3.37V7.37H9.68L11.46,5.6V3.82H0V19.45H11.6V15.81H3.37ZM7.52,1.18h.23l.36.62h.52L8.2,1.1A.51.51,0,0,0,8.53.59C8.53.16,8.19,0,7.77,0H7.05V1.8h.47Zm0-.81h.21c.22,0,.34,0,.34.22S8,.84,7.73.84H7.52ZM0,37H3.38V30.8H11V27.24H3.38v-2.3h7.8V21.41H0ZM.59,1.4h.58l.12.4h.49L1.17,0H.61L0,1.8H.48ZM.73.92C.78.74.83.54.88.35h0c0,.18.1.39.15.57l0,.15H.68Zm54.69.55a.82.82,0,0,1-.48-.18l-.27.29a1.19,1.19,0,0,0,.74.26c.47,0,.74-.26,.74-.56A.49.49,0,0,0,55.77.8L55.52.71c-.17-.06-.3-.1-.3-.2s.09-.15.24-.15a.67.67,0,0,1,.4.14L56.1.23A1,1,0,0,0,55.46,0c-.42,0-.71.24-.71.54a.52.52,0,0,0,.39.48l.26.1c.16.06.27.09.27.2S55.59,1.47,55.42,1.47ZM12.46,37h3.39V26.09H12.5l3.35-3.34V21.41H12.46ZM21.35,1.22c0-.22,0-.46-.06-.66h0l.19.39L22,1.8h.48V0H22V.62a6.26,6.26,0,0,0,.06.65h0L21.87.88,21.38,0H20.9V1.8h.45ZM28.45,0H28V1.8h.48ZM39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4ZM41.42,1.08h.65V1.8h.46V0h-.46V.71h-.65V0H41V1.8h.47Zm7,.72h.47V.39h.53V0H47.9V.39h.53Zm-13.59,0a1,1,0,0,0,.65-.22V.79h-.73v.35h.32v.29a.53.53,0,0,1-.19,0,.49.49,0,0,1-.54-.56.5.5,0,0,1,.5-.55.53.53,0,0,1,.36.14l.25-.27A.91.91,0,0,0,34.83,0a.91.91,0,0,0-1,.93A.88.88,0,0,0,34.84,1.84Zm-20.39-.5.21-.26.46.72h.52L14.93.74l.6-.71H15l-.56.7h0V0H14V1.8h.48Zm6.46,29.43h7.9V27.2h-7.9V24.88h6.33L29,23.13v-1.8H17.55V37h11.6V33.33H20.91Zm38.47,0h-.09v.12h.09ZM27.18,16.12V3.87H23.82v9.81L16.9,3.87H13.12v15.6h3.35V9.14l7.35,10.33ZM59.38,31h-.09v.13h.09Zm.56,0h-.18v.11h.18Zm8.89,2H66.91v.46h1.57v.74H66.91v.15l1.82,1.26v-.36l.5-.18V33.68h-.4ZM58.64,21.41V36.9h15.5V21.41Zm3.56,9.26h.22a.56.56,0,0,0,0-.12h.2l-.07.11h.32V31H63v.15h-.13v.25c0,.07,0,.11-.06.13a.36.36,0,0,1-.19,0,.42.42,0,0,0,0-.15h.1s0,0,0,0v-.24h-.39a.64.64,0,0,1-.2.42.63.63,0,0,0-.12-.11.52.52,0,0,0,.16-.31h-.14V31h.15Zm.38.75a.73.73,0,0,0-.18-.16l.1-.08a.55.55,0,0,1,.19.14Zm-1.51-.55v-.15h.45a.75.75,0,0,0-.06-.13l.16-.06s.06.12.08.16l-.08,0h.44v.15h-.55a.37.37,0,0,1,0,.11H62v.07c0,.29,0,.41-.09.46a.2.2,0,0,1-.13.06h-.19a.32.32,0,0,0-.06-.15h.24s0-.11.06-.28h-.32a.65.65,0,0,1-.31.46.45.45,0,0,0-.11-.13.61.61,0,0,0,.28-.59Zm-.87-.26H61v1h-.17V31.5h-.45v.07H60.2Zm-.59,0h.48v.82c0,.08,0,.12-.06.14a.38.38,0,0,1-.2,0,.47.47,0,0,0-.06-.15h.14s0,0,0,0v-.17h-.2a.54.54,0,0,1-.18.35.58.58,0,0,0-.12-.1.61.61,0,0,0,.17-.5Zm-.47,0h.38v.67h-.23v.09h-.15Zm0,2.74L60,31.76h.92l-1.23,2.33h-.57Zm2,2.84-2,.4v-.7l2-.41Zm12.79.41H71.45l-.72-.37V34.37l-.42.16v-.85h-.24v1l.46-.17v1l-1.62.6v.44l-2-1.42v1.38H66V35.21L64,36.6H62.82l-1.67-1.19.62-.46,1.65,1.14L66,34.31v-.15H64.41v-.74H66V33h-2v.18l-.86.6,1,.64v.88l-1.6-1.1-1.47,1v.12l-1.92.41v-.25l1.6-2.76H61l.68-.91h.9l-.32.43H66v-.46h.92v.46h2v.72h.27V32h.84v.94h.46v.6l.2-.08V32.29h.84v.85l.21-.08v-1.3h.84v1l1-.4v2.54l-.84.35V33.57l-.21.08V35.3l-.84.35V34l-.21.08v1.78h2.32Zm-12-1.78.63-.46.86.59v.92Zm.59-1.5L63,33H61.89Zm-2.5-2.58h-.18v.11h.18Zm1.14,3.07h-.21l-.43.83.38-.09v-.1l1-.72-.47-.32ZM42.62,33.2h0ZM34.05,21.39H30.66V37H41.59V33.11H34.05Zm22.86,3.87A4.74,4.74,0,0,0,56,23.72a6.75,6.75,0,0,0-1.4-1.24,6.06,6.06,0,0,0-2-.85,11.64,11.64,0,0,0-2.75-.3h-7.2V33.19l3.4-3.4V25h3.54q4.36,0,4.36,4v.13q0,4-4.36,4H42.63V37h7.22a9.91,9.91,0,0,0,3.22-.48,6.29,6.29,0,0,0,2.22-1.22,5.84,5.84,0,0,0,1.34-1.78,7.62,7.62,0,0,0,.69-2,11.54,11.54,0,0,0,.18-2.09v-.63A11.17,11.17,0,0,0,57.36,27,9.43,9.43,0,0,0,56.91,25.26Zm3.91,5.51h-.45V31h.45Zm0,.36h-.45v.21h.45Zm1.59-.23.1-.08h-.15V31h.19A.55.55,0,0,0,62.41,30.9Zm.17.12h.16v-.2h-.22a.61.61,0,0,1,.15.12Z";
const LOGO_EF_END_D_PATH = "M39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4Z";
const LOGO_TEXT_PATH = "M18.298828125 7.857421875 V26.876953125 Q18.298828125 30.111328125 18.087890625 31.4208984375 Q17.876953125 32.73046875 16.83984375 34.1103515625 Q15.802734375 35.490234375 14.1064453125 36.2021484375 Q12.41015625 36.9140625 10.107421875 36.9140625 Q7.55859375 36.9140625 5.607421875 36.0703125 Q3.65625 35.2265625 2.689453125 33.873046875 Q1.72265625 32.51953125 1.546875 31.0166015625 Q1.37109375 29.513671875 1.37109375 24.697265625 V7.857421875 H8.771484375 V29.197265625 Q8.771484375 31.060546875 8.9736328125 31.5791015625 Q9.17578125 32.09765625 9.791015625 32.09765625 Q10.494140625 32.09765625 10.6962890625 31.5263671875 Q10.8984375 30.955078125 10.8984375 28.828125 V7.857421875 Z M37.6875 7.857421875 V36.31640625 H31.201171875 L27.3515625 23.37890625 V36.31640625 H21.1640625 V7.857421875 H27.3515625 L31.5 20.671875 V7.857421875 Z M57.9375 20.267578125 H50.537109375 V15.310546875 Q50.537109375 13.1484375 50.2998046875 12.6123046875 Q50.0625 12.076171875 49.25390625 12.076171875 Q48.33984375 12.076171875 48.09375 12.7265625 Q47.84765625 13.376953125 47.84765625 15.5390625 V28.7578125 Q47.84765625 30.83203125 48.09375 31.46484375 Q48.33984375 32.09765625 49.201171875 32.09765625 Q50.02734375 32.09765625 50.2822265625 31.46484375 Q50.537109375 30.83203125 50.537109375 28.494140625 V24.92578125 H57.9375 V26.033203125 Q57.9375 30.4453125 57.3134765625 32.291015625 Q56.689453125 34.13671875 54.5537109375 35.525390625 Q52.41796875 36.9140625 49.2890625 36.9140625 Q46.037109375 36.9140625 43.927734375 35.736328125 Q41.818359375 34.55859375 41.1328125 32.4755859375 Q40.447265625 30.392578125 40.447265625 26.208984375 V17.89453125 Q40.447265625 14.818359375 40.658203125 13.2802734375 Q40.869140625 11.7421875 41.9150390625 10.318359375 Q42.9609375 8.89453125 44.8154296875 8.0771484375 Q46.669921875 7.259765625 49.078125 7.259765625 Q52.34765625 7.259765625 54.474609375 8.525390625 Q56.6015625 9.791015625 57.26953125 11.6806640625 Q57.9375 13.5703125 57.9375 17.560546875 Z M60.591796875 7.857421875 H72.931640625 V13.552734375 H67.9921875 V18.94921875 H72.615234375 V24.36328125 H67.9921875 V30.62109375 H73.423828125 V36.31640625 H60.591796875 Z M92.07421875 7.857421875 V36.31640625 H85.587890625 L81.73828125 23.37890625 V36.31640625 H75.55078125 V7.857421875 H81.73828125 L85.88671875 20.671875 V7.857421875 Z M110.724609375 16.470703125 H103.8515625 V14.361328125 Q103.8515625 12.884765625 103.587890625 12.48046875 Q103.32421875 12.076171875 102.708984375 12.076171875 Q102.041015625 12.076171875 101.6982421875 12.62109375 Q101.35546875 13.166015625 101.35546875 14.2734375 Q101.35546875 15.697265625 101.7421875 16.41796875 Q102.111328125 17.138671875 103.833984375 18.158203125 Q108.7734375 21.09375 110.056640625 22.974609375 Q111.33984375 24.85546875 111.33984375 29.0390625 Q111.33984375 32.080078125 110.6279296875 33.521484375 Q109.916015625 34.962890625 107.876953125 35.9384765625 Q105.837890625 36.9140625 103.130859375 36.9140625 Q100.16015625 36.9140625 98.0595703125 35.7890625 Q95.958984375 34.6640625 95.30859375 32.923828125 Q94.658203125 31.18359375 94.658203125 27.984375 V26.12109375 H101.53125 V29.583984375 Q101.53125 31.18359375 101.8212890625 31.640625 Q102.111328125 32.09765625 102.849609375 32.09765625 Q103.587890625 32.09765625 103.9482421875 31.517578125 Q104.30859375 30.9375 104.30859375 29.794921875 Q104.30859375 27.28125 103.623046875 26.5078125 Q102.919921875 25.734375 100.16015625 23.923828125 Q97.400390625 22.095703125 96.50390625 21.26953125 Q95.607421875 20.443359375 95.0185546875 18.984375 Q94.4296875 17.525390625 94.4296875 15.2578125 Q94.4296875 11.98828125 95.2646484375 10.4765625 Q96.099609375 8.96484375 97.962890625 8.1123046875 Q99.826171875 7.259765625 102.462890625 7.259765625 Q105.345703125 7.259765625 107.3759765625 8.19140625 Q109.40625 9.123046875 110.0654296875 10.5380859375 Q110.724609375 11.953125 110.724609375 15.345703125 Z M130.5703125 24.521484375 Q130.5703125 28.810546875 130.3681640625 30.5947265625 Q130.166015625 32.37890625 129.1025390625 33.85546875 Q128.0390625 35.33203125 126.228515625 36.123046875 Q124.41796875 36.9140625 122.009765625 36.9140625 Q119.724609375 36.9140625 117.9052734375 36.1669921875 Q116.0859375 35.419921875 114.978515625 33.92578125 Q113.87109375 32.431640625 113.66015625 30.673828125 Q113.44921875 28.916015625 113.44921875 24.521484375 V19.65234375 Q113.44921875 15.36328125 113.6513671875 13.5791015625 Q113.853515625 11.794921875 114.9169921875 10.318359375 Q115.98046875 8.841796875 117.791015625 8.05078125 Q119.6015625 7.259765625 122.009765625 7.259765625 Q124.294921875 7.259765625 126.1142578125 8.0068359375 Q127.93359375 8.75390625 129.041015625 10.248046875 Q130.1484375 11.7421875 130.359375 13.5 Q130.5703125 15.2578125 130.5703125 19.65234375 Z M123.169921875 15.169921875 Q123.169921875 13.18359375 122.9501953125 12.6298828125 Q122.73046875 12.076171875 122.044921875 12.076171875 Q121.46484375 12.076171875 121.1572265625 12.5244140625 Q120.849609375 12.97265625 120.849609375 15.169921875 V28.458984375 Q120.849609375 30.9375 121.0517578125 31.517578125 Q121.25390625 32.09765625 121.9921875 32.09765625 Q122.748046875 32.09765625 122.958984375 31.4296875 Q123.169921875 30.76171875 123.169921875 28.248046875 Z M133.330078125 7.857421875 H138.568359375 Q143.806640625 7.857421875 145.6611328125 8.26171875 Q147.515625 8.666015625 148.6845703125 10.3271484375 Q149.853515625 11.98828125 149.853515625 15.626953125 Q149.853515625 18.94921875 149.02734375 20.091796875 Q148.201171875 21.234375 145.775390625 21.462890625 Q147.97265625 22.0078125 148.728515625 22.921875 Q149.484375 23.8359375 149.6689453125 24.6005859375 Q149.853515625 25.365234375 149.853515625 28.810546875 V36.31640625 H142.98046875 V26.859375 Q142.98046875 24.57421875 142.6201171875 24.029296875 Q142.259765625 23.484375 140.73046875 23.484375 V36.31640625 H133.330078125 Z M140.73046875 12.7265625 V19.0546875 Q141.978515625 19.0546875 142.4794921875 18.7119140625 Q142.98046875 18.369140625 142.98046875 16.48828125 V14.923828125 Q142.98046875 13.5703125 142.4970703125 13.1484375 Q142.013671875 12.7265625 140.73046875 12.7265625 Z M152.71875 7.857421875 H165.05859375 V13.552734375 H160.119140625 V18.94921875 H164.7421875 V24.36328125 H160.119140625 V30.62109375 H165.55078125 V36.31640625 H152.71875 Z M167.677734375 7.857421875 H173.21484375 Q178.576171875 7.857421875 180.4658203125 8.349609375 Q182.35546875 8.841796875 183.33984375 9.966796875 Q184.32421875 11.091796875 184.5703125 12.4716796875 Q184.81640625 13.8515625 184.81640625 17.89453125 V27.861328125 Q184.81640625 31.693359375 184.4560546875 32.9853515625 Q184.095703125 34.27734375 183.19921875 35.0068359375 Q182.302734375 35.736328125 180.984375 36.0263671875 Q179.666015625 36.31640625 177.01171875 36.31640625 H167.677734375 Z M175.078125 12.7265625 V31.447265625 Q176.677734375 31.447265625 177.046875 30.8056640625 Q177.416015625 30.1640625 177.416015625 27.31640625 V16.259765625 Q177.416015625 14.326171875 177.29296875 13.78125 Q177.169921875 13.236328125 176.73046875 12.9814453125 Q176.291015625 12.7265625 175.078125 12.7265625 Z";

const LOGO_BASE_PATH_LAYERS = [_]Ui.SvgPathLayer{
    .{ .path = LOGO_EF_PATH, .transform = .{ .a = 2.211, .d = 2.211, .e = 13.0, .f = 3.0 } },
    .{ .path = LOGO_TEXT_PATH, .transform = .{ .a = 0.893583, .d = 0.2, .e = 11.774814, .f = 84.0 } },
};

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
    stay_open_after_inject: void,
    close_after_inject: void,
};

const TrackedProcessMode = enum {
    none,
    injected,
    startup_blocked,
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
    tracked_mode: TrackedProcessMode = .none,
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

const BoolOverride = cli.BoolOverride;

const PostInjectBehavior = enum {
    close,
    minimize,
    stay_open,
};

const GameLaunchMode = enum {
    normal,
    dx11,
    efmi,
};

const OutputDragMode = enum {
    none,
    select,
    scrollbar,
};

const OutputTextLayout = struct {
    layout: bytegui.TextLayoutResult,
    viewport: ByteVec2,
    overflow: bool,

    fn deinit(self: *OutputTextLayout) void {
        self.layout.deinit();
    }
};

const OutputSelectionRange = struct {
    start: usize,
    end: usize,
};

const LogoBounds = struct {
    min: ByteVec2 = .{},
    max: ByteVec2 = .{},
    valid: bool = false,
};

// App state
var g_hwnd: ?c.HWND = null;
var g_running = true;
var g_window_opacity: f32 = 0.0;
var g_wine_mode = false;
var g_allow_minimize = true;
var g_startup_target_pid: u32 = 0;

var g_font_textbox: ?*ByteFont = null;
var g_font_version: ?*ByteFont = null;
var g_font_launch: ?*ByteFont = null;
var g_font_toggle: ?*ByteFont = null;

var g_logo_layers: [LOGO_BASE_PATH_LAYERS.len]?Ui.ParsedSvgLayer = .{null} ** LOGO_BASE_PATH_LAYERS.len;
var g_logo_bounds: LogoBounds = .{};
var g_logo_end_d_bounds: LogoBounds = .{};
var g_logo_end_d_contact: ?ByteVec2 = null;
var g_launch_label_texture: TextTexture = .{};
var g_toggle_label_texture: TextTexture = .{};
var g_efmi_top_label_texture: TextTexture = .{};
var g_efmi_bottom_label_texture: TextTexture = .{};

var g_output_lines: std.ArrayListUnmanaged([]u8) = .empty;
var g_output_scroll_y: f32 = 0.0;
var g_output_content_height: f32 = 0.0;
var g_output_pending_autoscroll = true;
var g_output_selection_anchor: ?usize = null;
var g_output_selection_cursor: usize = 0;
var g_output_selection_highlight: bytegui.TextSelectionHighlightState = .{};
var g_output_scrollbar_visual: bytegui.ScrollbarVisualState = .{};
var g_output_drag_mode: OutputDragMode = .none;
var g_output_scroll_drag_start_y: i32 = 0;
var g_output_scroll_drag_start_scroll: f32 = 0.0;
var g_minimize_on_launch = false;
var g_efmi_on_launch = false;
var g_efmi_requested = false;
var g_efmi_search_enabled = true;
var g_efmi_button_visible = false;
var g_efmi_launcher_path: ?[]const u8 = null;
var g_efmi_detected_launcher_path: ?[]u8 = null;
var g_minimized_by_toggle = false;
var g_stayed_open_by_toggle = false;
var g_game_exe_path: ?[:0]u16 = null;
var g_game_exe_override_path: ?[]const u8 = null;
var g_environ: std.process.Environ = .empty;
var g_launch_btn_enabled = false;
var g_launch_cooldown_until_tick: u64 = 0;
var g_version_display_buf: [64]u8 = undefined;
var g_version_display: []const u8 = VERSION_STR;
var g_loader_thread: ?std.Thread = null;
var g_loader_control_mutex: ThreadMutex = .{};
var g_loader_events_mutex: ThreadMutex = .{};
var g_loader_should_stop = false;
var g_loader_minimize_on_launch = false;
var g_loader_allow_minimize = true;
var g_loader_target_running = false;
var g_force_dx11 = false;
var g_loader_pending_launch_mode: ?GameLaunchMode = null;
var g_loader_events: std.ArrayListUnmanaged(LoaderUiEvent) = .empty;

var g_hovered_button: i32 = 0;
var g_pressed_button: i32 = 0;
var g_press_captured = false;
var g_press_canceled = false;
var g_dragging = false;
var g_cursor_in_window = false;
var g_mouse_leave_tracking = false;
var g_hover_requires_cursor_motion = false;
var g_last_cursor_screen = std.mem.zeroes(c.POINT);
var g_last_cursor_screen_valid = false;
var g_press_screen: c.POINT = std.mem.zeroes(c.POINT);
var g_press_rect: c.RECT = std.mem.zeroes(c.RECT);
var g_drag_offset: c.POINT = std.mem.zeroes(c.POINT);
var g_was_minimized = false;
var g_launch_right_click_count: u8 = 0;
var g_launch_right_click_last_tick: u64 = 0;
var g_debug_options: cli.DebugOptions = .{};

var g_window_anim: WindowAnim = .{};
var g_close_countdown: CloseCountdown = .{};
var g_launch_anim: ScalarAnim = .{};
var g_launch_label_anim: ScalarAnim = .{};
var g_toggle_anim: ScalarAnim = .{};
var g_efmi_anim: ScalarAnim = .{};
var g_efmi_label_anim: ScalarAnim = .{};
var g_button_colors = [_]ColorAnim{.{}} ** 5;
var g_toggle_current_color = ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };
var g_efmi_current_color = ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };
var g_launch_current_color = ByteVec4{ .x = 180.0 / 255.0, .y = 180.0 / 255.0, .z = 180.0 / 255.0, .w = 1.0 };

const kControlIdleColor = ByteVec4{ .x = 51.0 / 255.0, .y = 51.0 / 255.0, .z = 51.0 / 255.0, .w = 1.0 };
const kControlHoverBlue = ByteVec4{ .x = 100.0 / 255.0, .y = 149.0 / 255.0, .z = 237.0 / 255.0, .w = 1.0 };
const kLaunchEnabledColor = ByteVec4{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 };
const kLaunchDisabledColor = ByteVec4{ .x = 180.0 / 255.0, .y = 180.0 / 255.0, .z = 180.0 / 255.0, .w = 1.0 };
const kDebugWindowBoundsColor = ByteVec4{ .x = 0.65, .y = 0.20, .z = 1.00, .w = 1.0 };
const kDebugVisualBoundsColor = ByteVec4{ .x = 0.00, .y = 0.35, .z = 1.00, .w = 1.0 };
const kDebugHitboxColor = ByteVec4{ .x = 1.00, .y = 0.05, .z = 0.05, .w = 1.0 };
const kDebugTextBoundsColor = ByteVec4{ .x = 0.00, .y = 0.72, .z = 0.15, .w = 1.0 };
const kDebugLogoBoundsColor = ByteVec4{ .x = 1.00, .y = 0.48, .z = 0.00, .w = 1.0 };
const kDebugScrollbarBoundsColor = ByteVec4{ .x = 0.00, .y = 0.75, .z = 0.90, .w = 1.0 };
const kDebugConstraintBoundsColor = ByteVec4{ .x = 1.00, .y = 0.85, .z = 0.00, .w = 1.0 };
const kDebugGuideLineColor = ByteVec4{ .x = 1.00, .y = 1.00, .z = 1.00, .w = 1.0 };
const kDebugCenterLineColor = ByteVec4{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 };
const DEBUG_BOX_OVERLAY_OPACITY = 0.64;
const DEBUG_BOX_CONSTRAINT_OPACITY = 0.70;
const DEBUG_BOX_GUIDE_OPACITY = 0.52;
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
const makeRectL = c.makeRectL;
const pointInRect = c.pointInRect;
const loadCursorResource = c.loadCursorResource;
const wtf8ToWtf16LeZ = c.wtf8ToWtf16LeZ;

// Basic helpers
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

fn highWordSignedWParam(value: c.WPARAM) i32 {
    const hi: u16 = @truncate((value >> 16) & 0xFFFF);
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

fn darkerEfmiShadowColor(color: ByteVec4) ByteVec4 {
    return .{
        .x = color.x * EFMI_SHADOW_DARKEN,
        .y = color.y * EFMI_SHADOW_DARKEN,
        .z = color.z * EFMI_SHADOW_DARKEN,
        .w = color.w,
    };
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

fn fromByteGuiRect(rect: bgc.RECT) c.RECT {
    return .{
        .left = rect.left,
        .top = rect.top,
        .right = rect.right,
        .bottom = rect.bottom,
    };
}

fn isRunningUnderWine() bool {
    const ntdll = c.GetModuleHandleA("ntdll.dll") orelse return false;
    return c.GetProcAddress(ntdll, "wine_get_version") != null;
}

fn resolveWineMode(config: cli.LaunchConfig) bool {
    return switch (config.wine_mode_override) {
        .auto => isRunningUnderWine(),
        .on => true,
        .off => false,
    };
}

fn resolveAllowMinimize(config: cli.LaunchConfig, wine_mode: bool) bool {
    return switch (config.allow_minimize_override) {
        .auto => !wine_mode,
        .on => true,
        .off => false,
    };
}

fn resolvePostInjectBehavior(toggle_enabled: bool, allow_minimize: bool) PostInjectBehavior {
    if (!toggle_enabled) return .close;
    return if (allow_minimize) .minimize else .stay_open;
}

fn guiPostInjectBehavior() PostInjectBehavior {
    return resolvePostInjectBehavior(g_minimize_on_launch, g_allow_minimize);
}

fn loaderPostInjectBehavior() PostInjectBehavior {
    g_loader_control_mutex.lock();
    defer g_loader_control_mutex.unlock();
    return resolvePostInjectBehavior(g_loader_minimize_on_launch, g_loader_allow_minimize);
}

fn setLoaderTargetRunning(running: bool) void {
    g_loader_control_mutex.lock();
    g_loader_target_running = running;
    g_loader_control_mutex.unlock();
}

fn loaderTargetRunning() bool {
    g_loader_control_mutex.lock();
    defer g_loader_control_mutex.unlock();
    return g_loader_target_running;
}

fn setLoaderPendingLaunchMode(mode: ?GameLaunchMode) void {
    g_loader_control_mutex.lock();
    g_loader_pending_launch_mode = mode;
    g_loader_control_mutex.unlock();
}

fn takeLoaderPendingLaunchMode() ?GameLaunchMode {
    g_loader_control_mutex.lock();
    defer g_loader_control_mutex.unlock();
    const pending = g_loader_pending_launch_mode;
    g_loader_pending_launch_mode = null;
    return pending;
}

fn defaultLaunchMode() GameLaunchMode {
    return if (g_force_dx11) .dx11 else .normal;
}

fn alternateLaunchMode() GameLaunchMode {
    return if (g_force_dx11) .normal else .dx11;
}

fn efmiLaunchSelected() bool {
    return g_efmi_button_visible and g_efmi_on_launch;
}

fn selectedLaunchMode(preferred_mode: GameLaunchMode) GameLaunchMode {
    return if (efmiLaunchSelected()) .efmi else preferred_mode;
}

fn appendLaunchModeStatus(mode: GameLaunchMode) void {
    switch (mode) {
        .normal => appendStatus(strings.status_launching_game_vulkan, .{}),
        .dx11 => appendStatus(strings.status_launching_game_dx11, .{}),
        .efmi => appendStatus(strings.status_launching_efmi, .{}),
    }
}

fn queueLaunchModeStatus(mode: GameLaunchMode) void {
    switch (mode) {
        .normal => queueLoaderStatus(strings.status_launching_game_vulkan, .{}),
        .dx11 => queueLoaderStatus(strings.status_launching_game_dx11, .{}),
        .efmi => queueLoaderStatus(strings.status_launching_efmi, .{}),
    }
}

fn launchCooldownActive() bool {
    if (g_launch_cooldown_until_tick == 0) return false;
    if (c.GetTickCount64() < g_launch_cooldown_until_tick) return true;
    g_launch_cooldown_until_tick = 0;
    return false;
}

fn startLaunchCooldown(mode: GameLaunchMode) void {
    const cooldown_ms: u64 = switch (mode) {
        .efmi => EFMI_LAUNCH_COOLDOWN_MS,
        .normal, .dx11 => LAUNCH_COOLDOWN_MS,
    };
    g_launch_cooldown_until_tick = c.GetTickCount64() + cooldown_ms;
    updateLaunchButtonState();
}

fn computeLaunchButtonEnabled() bool {
    if (launchCooldownActive()) return false;
    if (loaderTargetRunning()) return false;
    if (efmiLaunchSelected()) return true;
    return g_game_exe_path != null;
}

fn syncLaunchButtonStateImmediate() void {
    g_launch_btn_enabled = computeLaunchButtonEnabled();
    g_launch_current_color = if (g_launch_btn_enabled) kLaunchEnabledColor else kLaunchDisabledColor;
}

fn updateLaunchButtonState() void {
    g_launch_btn_enabled = computeLaunchButtonEnabled();
    if (!g_launch_btn_enabled and (g_hovered_button == 5 or g_hovered_button == 7)) applyHoveredButton(0);
}

fn toggleButtonLabel() []const u8 {
    return if (g_allow_minimize) LABEL_MINIMIZE else LABEL_STAY_OPEN;
}

fn allocOwnedLine(comptime fmt: []const u8, args: anytype) ?[]u8 {
    return std.fmt.allocPrint(allocator, fmt, args) catch null;
}

fn clearOutputSelection() void {
    g_output_selection_anchor = null;
    g_output_selection_cursor = 0;
}

fn scheduleOutputAutoscroll() void {
    g_output_pending_autoscroll = true;
}

// Status text
fn appendStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    appendOwnedStatusLine(line);
}

fn appendOwnedStatusLine(line: []u8) void {
    g_output_lines.append(allocator, line) catch allocator.free(line);
    scheduleOutputAutoscroll();
}

fn setLastOwnedStatusLine(line: []u8) void {
    if (g_output_lines.items.len == 0) {
        appendOwnedStatusLine(line);
        return;
    }

    const last_index = g_output_lines.items.len - 1;
    allocator.free(g_output_lines.items[last_index]);
    g_output_lines.items[last_index] = line;
    scheduleOutputAutoscroll();
}

fn clearStatusLines() void {
    for (g_output_lines.items) |line| allocator.free(line);
    g_output_lines.deinit(allocator);
    g_output_lines = .empty;
    g_output_scroll_y = 0.0;
    g_output_content_height = 0.0;
    clearOutputSelection();
    scheduleOutputAutoscroll();
}

fn cancelCloseCountdown() void {
    g_close_countdown = .{};
}

fn makeCountdownStatusLine(action: CloseCountdown.Action, seconds_remaining: i32) ?[]u8 {
    const action_text = if (action == .minimize) strings.countdown_action_minimize else strings.countdown_action_close;

    if (seconds_remaining == 1) {
        return allocOwnedLine(strings.status_countdown_one_fmt, .{ action_text, seconds_remaining });
    }

    return allocOwnedLine(strings.status_countdown_many_fmt, .{ action_text, seconds_remaining });
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

// Worker events
fn freeLoaderEvent(event: LoaderUiEvent) void {
    switch (event) {
        .status_line => |line| allocator.free(line),
        .replace_last_status_line => |line| allocator.free(line),
        else => {},
    }
}

fn queueLoaderEvent(event: LoaderUiEvent) void {
    g_loader_events_mutex.lock();
    defer g_loader_events_mutex.unlock();
    g_loader_events.append(allocator, event) catch freeLoaderEvent(event);
}

fn queueLoaderStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    queueLoaderEvent(.{ .status_line = line });
}

fn queueLoaderReplaceLastStatus(comptime fmt: []const u8, args: anytype) void {
    const line = allocOwnedLine(fmt, args) orelse return;
    queueLoaderEvent(.{ .replace_last_status_line = line });
}

fn takeLoaderEvents() std.ArrayListUnmanaged(LoaderUiEvent) {
    var pending: std.ArrayListUnmanaged(LoaderUiEvent) = .empty;
    g_loader_events_mutex.lock();
    defer g_loader_events_mutex.unlock();
    std.mem.swap(std.ArrayListUnmanaged(LoaderUiEvent), &pending, &g_loader_events);
    return pending;
}

fn drainLoaderEvents() void {
    var pending = takeLoaderEvents();
    defer pending.deinit(allocator);

    for (pending.items) |event| {
        switch (event) {
            .clear_status => clearStatusLines(),
            .status_line => |line| appendOwnedStatusLine(line),
            .replace_last_status_line => |line| setLastOwnedStatusLine(line),
            .process_closed => maybeRestoreAfterExit(),
            .minimize_after_inject => {
                g_minimized_by_toggle = true;
                g_stayed_open_by_toggle = false;
                if (g_window_anim.typ == .none) startCountdown(.minimize);
            },
            .stay_open_after_inject => {
                g_minimized_by_toggle = false;
                g_stayed_open_by_toggle = true;
            },
            .close_after_inject => {
                g_minimized_by_toggle = false;
                g_stayed_open_by_toggle = false;
                if (g_window_anim.typ == .none) startCountdown(.close);
            },
        }
    }
}

fn clearLoaderEvents() void {
    var pending = takeLoaderEvents();
    defer pending.deinit(allocator);

    for (pending.items) |event| freeLoaderEvent(event);
}

fn setLoaderMinimizeOnLaunch(enabled: bool) void {
    g_minimize_on_launch = enabled;
    g_loader_control_mutex.lock();
    g_loader_minimize_on_launch = enabled;
    g_loader_control_mutex.unlock();
}

fn setEfmiOnLaunch(enabled: bool) void {
    g_efmi_on_launch = enabled;
    updateLaunchButtonState();
}

fn clearDetectedEfmiLauncherPath() void {
    if (g_efmi_detected_launcher_path) |path| {
        if (g_efmi_launcher_path) |active_path| {
            if (active_path.ptr == path.ptr) g_efmi_launcher_path = null;
        }
        allocator.free(path);
        g_efmi_detected_launcher_path = null;
    }
}

fn refreshEfmiAvailability() void {
    clearDetectedEfmiLauncherPath();
    if (!g_efmi_search_enabled) {
        g_efmi_launcher_path = null;
        g_efmi_button_visible = false;
        g_efmi_on_launch = false;
        return;
    }
    if (g_efmi_requested) {
        g_efmi_button_visible = true;
        return;
    }

    if (cli.resolveDefaultEfmiLauncherPath(allocator, g_environ) catch null) |path| {
        g_efmi_detected_launcher_path = path;
        g_efmi_launcher_path = path;
        g_efmi_button_visible = true;
    } else {
        g_efmi_button_visible = false;
        g_efmi_on_launch = false;
    }
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
            if (state.tracked_mode == .startup_blocked) {
                queueLoaderEvent(.{ .clear_status = {} });
            }
            queueLoaderStatus(strings.status_game_process_closed, .{});
            state.tracked_pid = 0;
            state.last_failed_pid = 0;
            state.tracked_mode = .none;
            setLoaderTargetRunning(false);
            queueLoaderEvent(.{ .process_closed = {} });
        } else {
            setLoaderTargetRunning(true);
        }
        return;
    }

    const pid = loader.findTargetProcess();
    if (pid == 0) {
        state.last_failed_pid = 0;
        setLoaderTargetRunning(false);
        return;
    }
    setLoaderTargetRunning(true);
    if (pid == state.last_failed_pid) return;

    queueLoaderEvent(.{ .clear_status = {} });
    if (takeLoaderPendingLaunchMode()) |launch_mode| {
        queueLaunchModeStatus(launch_mode);
    }
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
        state.tracked_mode = .injected;
        switch (loaderPostInjectBehavior()) {
            .close => queueLoaderEvent(.{ .close_after_inject = {} }),
            .minimize => queueLoaderEvent(.{ .minimize_after_inject = {} }),
            .stay_open => queueLoaderEvent(.{ .stay_open_after_inject = {} }),
        }
    } else |err| {
        queueLoaderReplaceLastStatus(strings.status_injection_failed_fmt, .{loader.describeInjectError(err)});
        if (loader.injectErrorSuggestsElevation(err)) {
            queueLoaderStatus(strings.status_try_run_admin, .{});
        }
        state.last_failed_pid = pid;
    }
}

fn loaderWorkerMain(startup_target_pid: u32) void {
    var state = LoaderWorkerState{};
    defer state.deinit();
    if (startup_target_pid != 0 and loader.isProcessAlive(startup_target_pid)) {
        state.tracked_pid = startup_target_pid;
        state.tracked_mode = .startup_blocked;
        setLoaderTargetRunning(true);
    }

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
    g_loader_allow_minimize = g_allow_minimize;
    g_loader_control_mutex.unlock();

    g_loader_thread = std.Thread.spawn(.{}, loaderWorkerMain, .{g_startup_target_pid}) catch return false;
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

// Cached render assets
fn cleanupLogoLayers() void {
    for (&g_logo_layers) |*slot| {
        if (slot.*) |*layer| layer.deinit();
        slot.* = null;
    }
    g_logo_bounds = .{};
    g_logo_end_d_bounds = .{};
    g_logo_end_d_contact = null;
}

fn deinitLogoLayerSlots(slots: []?Ui.ParsedSvgLayer) void {
    for (slots) |*slot| {
        if (slot.*) |*layer| layer.deinit();
        slot.* = null;
    }
}

fn logoBoundsFromSlots(slots: []const ?Ui.ParsedSvgLayer) LogoBounds {
    var bounds = LogoBounds{};
    for (slots) |slot| {
        const layer = slot orelse continue;
        if (layer.bounds_min.x >= layer.bounds_max.x or layer.bounds_min.y >= layer.bounds_max.y) continue;
        if (!bounds.valid) {
            bounds = .{ .min = layer.bounds_min, .max = layer.bounds_max, .valid = true };
        } else {
            bounds.min.x = @min(bounds.min.x, layer.bounds_min.x);
            bounds.min.y = @min(bounds.min.y, layer.bounds_min.y);
            bounds.max.x = @max(bounds.max.x, layer.bounds_max.x);
            bounds.max.y = @max(bounds.max.y, layer.bounds_max.y);
        }
    }
    return bounds;
}

fn scaledLogoLayer(base: Ui.SvgPathLayer, scale: f32, tx: f32, ty: f32) Ui.SvgPathLayer {
    return .{
        .path = base.path,
        .transform = .{
            .a = base.transform.a * scale,
            .b = base.transform.b * scale,
            .c = base.transform.c * scale,
            .d = base.transform.d * scale,
            .e = base.transform.e * scale + tx,
            .f = base.transform.f * scale + ty,
        },
    };
}

fn cleanupButtonLabelTextures() void {
    Ui.CleanupTextTexture(&g_launch_label_texture);
    Ui.CleanupTextTexture(&g_toggle_label_texture);
    Ui.CleanupTextTexture(&g_efmi_top_label_texture);
    Ui.CleanupTextTexture(&g_efmi_bottom_label_texture);
}

fn buildButtonLabelTexture(out_texture: *TextTexture, font: ?*ByteFont, logical_font_size: f32, text: []const u8, pad_scale: f32) bool {
    return Ui.BuildTextTexture(
        out_texture,
        font,
        logical_font_size * BUTTON_LABEL_RENDER_SCALE,
        text,
        BUTTON_LABEL_SUPERSAMPLE,
        pad_scale,
        1.0 / BUTTON_LABEL_RENDER_SCALE,
    );
}

fn rasterizeButtonLabelTexture(font: ?*ByteFont, logical_font_size: f32, text: []const u8, pad_scale: f32) ?Ui.RasterizedTexture {
    return Ui.RasterizeTextTexture(
        font,
        logical_font_size * BUTTON_LABEL_RENDER_SCALE,
        text,
        BUTTON_LABEL_SUPERSAMPLE,
        pad_scale,
        1.0 / BUTTON_LABEL_RENDER_SCALE,
    );
}

const EfmiLabelLines = struct {
    top: []const u8,
    bottom: []const u8,
};

fn efmiLabelLines() EfmiLabelLines {
    const split = std.mem.indexOfScalar(u8, LABEL_EFMI, '\n') orelse LABEL_EFMI.len;
    return .{
        .top = LABEL_EFMI[0..split],
        .bottom = if (split < LABEL_EFMI.len) LABEL_EFMI[split + 1 ..] else LABEL_EFMI[split..],
    };
}

fn rebuildButtonLabelTextures() bool {
    const efmi_lines = efmiLabelLines();
    const launch_ok = buildButtonLabelTexture(&g_launch_label_texture, g_font_launch, 24.0, LABEL_LAUNCH, 0.9);
    const toggle_ok = buildButtonLabelTexture(&g_toggle_label_texture, g_font_toggle, 20.0, toggleButtonLabel(), 0.45);
    const efmi_top_ok = buildButtonLabelTexture(&g_efmi_top_label_texture, g_font_toggle, EFMI_LABEL_LINE_SIZE, efmi_lines.top, 0.45);
    const efmi_bottom_ok = buildButtonLabelTexture(&g_efmi_bottom_label_texture, g_font_toggle, EFMI_LABEL_LINE_SIZE, efmi_lines.bottom, 0.45);
    return launch_ok and toggle_ok and efmi_top_ok and efmi_bottom_ok;
}

fn rebuildLogoLayers() void {
    cleanupLogoLayers();
    const dpi_scale = bytegui.ByteGui_ImplWin32_GetDpiScale();

    var base_layers: [LOGO_BASE_PATH_LAYERS.len]?Ui.ParsedSvgLayer = .{null} ** LOGO_BASE_PATH_LAYERS.len;
    defer deinitLogoLayerSlots(base_layers[0..]);
    for (&LOGO_BASE_PATH_LAYERS, 0..) |layer, i| {
        base_layers[i] = Ui.BuildParsedSvgLayer(layer, dpi_scale);
    }

    const base_bounds = logoBoundsFromSlots(base_layers[0..]);
    if (!base_bounds.valid) return;

    const coverage_pad = 1.0 / @max(dpi_scale, 1.0);
    const raw_min = ByteVec2{ .x = base_bounds.min.x + coverage_pad, .y = base_bounds.min.y + coverage_pad };
    const raw_max = ByteVec2{ .x = base_bounds.max.x - coverage_pad, .y = base_bounds.max.y - coverage_pad };
    const raw_w = @max(1.0, raw_max.x - raw_min.x);
    const raw_h = @max(1.0, raw_max.y - raw_min.y);
    const logo_scale = @max(0.01, (MAIN_CONTENT_SIZE - coverage_pad * 2.0) / raw_h);
    const logo_w = raw_w * logo_scale + coverage_pad * 2.0;
    const logo_right = WINDOW_WIDTH * 0.5 - MAIN_CONTENT_CENTER_EDGE_OFFSET;
    const target_min = ByteVec2{
        .x = logo_right - logo_w,
        .y = (WINDOW_HEIGHT - MAIN_CONTENT_SIZE) * 0.5,
    };
    const tx = target_min.x + coverage_pad - raw_min.x * logo_scale;
    const ty = target_min.y + coverage_pad - raw_min.y * logo_scale;

    for (&LOGO_BASE_PATH_LAYERS, 0..) |base, i| {
        g_logo_layers[i] = Ui.BuildParsedSvgLayer(scaledLogoLayer(base, logo_scale, tx, ty), dpi_scale);
    }
    g_logo_bounds = logoBoundsFromSlots(g_logo_layers[0..]);

    const end_d_layer = Ui.SvgPathLayer{
        .path = LOGO_EF_END_D_PATH,
        .transform = LOGO_BASE_PATH_LAYERS[0].transform,
    };
    if (Ui.BuildParsedSvgLayer(scaledLogoLayer(end_d_layer, logo_scale, tx, ty), dpi_scale)) |layer| {
        var measured_layer = layer;
        defer measured_layer.deinit();
        if (measured_layer.bounds_min.x < measured_layer.bounds_max.x and measured_layer.bounds_min.y < measured_layer.bounds_max.y) {
            g_logo_end_d_bounds = .{
                .min = measured_layer.bounds_min,
                .max = measured_layer.bounds_max,
                .valid = true,
            };
        }
        var contact = ByteVec2{};
        var contact_sum = -std.math.floatMax(f32);
        for (measured_layer.fill_vertices) |vertex| {
            const sum = vertex.pos.x + vertex.pos.y;
            if (sum > contact_sum) {
                contact_sum = sum;
                contact = vertex.pos;
            }
        }
        for (measured_layer.fringe_vertices) |vertex| {
            const sum = vertex.pos.x + vertex.pos.y;
            if (sum > contact_sum) {
                contact_sum = sum;
                contact = vertex.pos;
            }
        }
        if (contact_sum > -std.math.floatMax(f32)) g_logo_end_d_contact = contact;
    }
}

const StartupPreparedAssets = struct {
    launch_label: Ui.RasterizedTexture = .{},
    toggle_label: Ui.RasterizedTexture = .{},
    efmi_top_label: Ui.RasterizedTexture = .{},
    efmi_bottom_label: Ui.RasterizedTexture = .{},
    launch_label_ready: bool = false,
    toggle_label_ready: bool = false,
    efmi_top_label_ready: bool = false,
    efmi_bottom_label_ready: bool = false,

    fn deinit(self: *StartupPreparedAssets) void {
        if (self.launch_label_ready) Ui.CleanupRasterizedTexture(&self.launch_label);
        if (self.toggle_label_ready) Ui.CleanupRasterizedTexture(&self.toggle_label);
        if (self.efmi_top_label_ready) Ui.CleanupRasterizedTexture(&self.efmi_top_label);
        if (self.efmi_bottom_label_ready) Ui.CleanupRasterizedTexture(&self.efmi_bottom_label);
        self.* = .{};
    }
};

fn prepareStartupAssets(out_assets: *StartupPreparedAssets) void {
    out_assets.* = .{};
    const efmi_lines = efmiLabelLines();

    if (rasterizeButtonLabelTexture(g_font_launch, 24.0, LABEL_LAUNCH, 0.9)) |raster| {
        out_assets.launch_label = raster;
        out_assets.launch_label_ready = true;
    }
    if (rasterizeButtonLabelTexture(g_font_toggle, 20.0, toggleButtonLabel(), 0.45)) |raster| {
        out_assets.toggle_label = raster;
        out_assets.toggle_label_ready = true;
    }
    if (rasterizeButtonLabelTexture(g_font_toggle, EFMI_LABEL_LINE_SIZE, efmi_lines.top, 0.45)) |raster| {
        out_assets.efmi_top_label = raster;
        out_assets.efmi_top_label_ready = true;
    }
    if (rasterizeButtonLabelTexture(g_font_toggle, EFMI_LABEL_LINE_SIZE, efmi_lines.bottom, 0.45)) |raster| {
        out_assets.efmi_bottom_label = raster;
        out_assets.efmi_bottom_label_ready = true;
    }
}

fn startupAssetWorkerMain(out_assets: *StartupPreparedAssets) void {
    prepareStartupAssets(out_assets);
}

fn uploadPreparedStartupAssets(prepared: *const StartupPreparedAssets) bool {
    cleanupButtonLabelTextures();
    if (!prepared.launch_label_ready or !prepared.toggle_label_ready or !prepared.efmi_top_label_ready or !prepared.efmi_bottom_label_ready) return false;

    const launch_ok = Ui.UploadRasterizedMaskTexture(&g_launch_label_texture, &prepared.launch_label);
    const toggle_ok = Ui.UploadRasterizedMaskTexture(&g_toggle_label_texture, &prepared.toggle_label);
    const efmi_top_ok = Ui.UploadRasterizedMaskTexture(&g_efmi_top_label_texture, &prepared.efmi_top_label);
    const efmi_bottom_ok = Ui.UploadRasterizedMaskTexture(&g_efmi_bottom_label_texture, &prepared.efmi_bottom_label);
    return launch_ok and toggle_ok and efmi_top_ok and efmi_bottom_ok;
}

fn cleanupRenderResources() void {
    cleanupLogoLayers();
    cleanupButtonLabelTextures();
    g_output_selection_highlight.deinit();
}

fn windowUsesLayeredOpacity() bool {
    return !g_wine_mode;
}

fn windowCornerRadiusPx() f32 {
    return if (g_wine_mode) 0.0 else snapPixel(scaleF(CORNER_RADIUS));
}

fn applyWindowShape() void {
    const hwnd = g_hwnd orelse return;
    if (!windowUsesLayeredOpacity()) return;
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
    g_font_textbox = null;
    g_font_version = null;
    g_font_launch = null;
    g_font_toggle = null;

    var ui_cfg = ByteFontConfig{};
    ui_cfg.PixelSnapH = true;
    ui_cfg.OversampleH = 2;
    ui_cfg.OversampleV = 2;

    var body_cfg = ByteFontConfig{};
    body_cfg.PixelSnapH = false;
    body_cfg.OversampleH = 2;
    body_cfg.OversampleV = 2;

    g_font_toggle = io.Fonts.?.AddFontFromMemoryTTF(embedded_toggle_font, "toggle-label.ttf", scaleF(16.0), &ui_cfg);

    g_font_launch = io.Fonts.?.AddFontFromMemoryTTF(embedded_launch_font, "launch-button.ttf", scaleF(20.0), &ui_cfg);

    g_font_textbox = io.Fonts.?.AddFontFromMemoryTTF(embedded_textbox_font, "text-box.ttf", scaleF(13.0), &body_cfg);
    g_font_version = io.Fonts.?.AddFontFromMemoryTTF(embedded_version_font, "version-info.ttf", scaleF(12.0), &body_cfg);
}

fn refreshUiScaleResources() void {
    if (ByteGui.GetCurrentContext() == null) return;
    applyBaseStyle();
    loadFonts();
    if (bytegui.ByteGui_ImplOpenGL_HasContext()) {
        _ = rebuildButtonLabelTextures();
        rebuildLogoLayers();
    }
}

// Animation and drawing
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
    if (!windowUsesLayeredOpacity()) {
        g_window_opacity = 1.0;
        return true;
    }
    const hwnd = g_hwnd orelse return false;
    return c.SetLayeredWindowAttributes(hwnd, 0, 255, c.LWA_ALPHA) != c.FALSE;
}

fn setWindowOpacityImmediate(opacity: f32) bool {
    g_window_opacity = clamp01(opacity);
    if (!windowUsesLayeredOpacity()) return true;
    const hwnd = g_hwnd orelse return false;
    const alpha: c.BYTE = @intFromFloat(@round(g_window_opacity * 255.0));
    return c.SetLayeredWindowAttributes(hwnd, 0, alpha, c.LWA_ALPHA) != c.FALSE;
}

fn platformWindowSize() ByteVec2 {
    return .{
        .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()),
        .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()),
    };
}

fn moveWindowNoActivate(hwnd: c.HWND, pos: c.POINT) void {
    _ = c.SetWindowPos(hwnd, null, pos.x, pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
}

fn bringWindowToFront() void {
    const hwnd = g_hwnd orelse return;
    const fg = c.GetForegroundWindow();
    const our_tid = c.GetCurrentThreadId();
    const fg_tid = if (fg) |w| c.GetWindowThreadProcessId(w, null) else 0;

    const needs_thread_attach = fg_tid != 0 and fg_tid != our_tid;
    if (needs_thread_attach)
        _ = c.AttachThreadInput(our_tid, fg_tid, c.TRUE);
    defer {
        if (needs_thread_attach)
            _ = c.AttachThreadInput(our_tid, fg_tid, c.FALSE);
    }

    _ = c.SetForegroundWindow(hwnd);
}

fn showStartupWindow() void {
    const hwnd = g_hwnd orelse return;
    if (g_wine_mode) {
        _ = c.ShowWindow(hwnd, c.SW_SHOW);
        bringWindowToFront();
        _ = c.UpdateWindow(hwnd);
        _ = setWindowOpacityImmediate(1.0);
        return;
    }
    _ = setWindowOpacityImmediate(0.0);
    _ = c.ShowWindow(hwnd, c.SW_SHOW);
    bringWindowToFront();
    _ = c.UpdateWindow(hwnd);
    armHoverAfterCursorMotion();
    startWindowAnimation(.slide_in);
}

fn startWindowAnimation(typ: WindowAnimType) void {
    const hwnd = g_hwnd orelse return;
    var rc = std.mem.zeroes(c.RECT);
    _ = c.GetWindowRect(hwnd, &rc);

    cancelCloseCountdown();
    if (g_wine_mode) {
        g_window_anim = .{};
        switch (typ) {
            .slide_in, .fade_in_restore => {
                moveWindowNoActivate(hwnd, .{ .x = rc.left, .y = rc.top });
                _ = setWindowOpacityImmediate(1.0);
            },
            .slide_out_close => {
                _ = setWindowOpacityImmediate(1.0);
                _ = c.DestroyWindow(hwnd);
            },
            .fade_out_minimize => {
                _ = setWindowOpacityImmediate(1.0);
                if (g_minimized_by_toggle) {
                    const line = allocOwnedLine(strings.status_minimized, .{});
                    if (line) |owned_line| setLastOwnedStatusLine(owned_line);
                }
                _ = c.ShowWindow(hwnd, c.SW_MINIMIZE);
            },
            .none => {},
        }
        return;
    }

    g_window_anim = .{ .typ = typ };
    switch (typ) {
        .slide_in => {
            g_window_anim.duration = WINDOW_SLIDE_IN_DURATION;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top + scaleIF(WINDOW_SLIDE_IN_OFFSET) };
            g_window_anim.end_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.start_opacity = 0.0;
            g_window_anim.end_opacity = 1.0;
            moveWindowNoActivate(hwnd, g_window_anim.start_pos);
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
            armHoverAfterCursorMotion();
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

    for (&[_]*ScalarAnim{ &g_launch_anim, &g_launch_label_anim, &g_toggle_anim, &g_efmi_anim, &g_efmi_label_anim }) |anim| {
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
    const efmi_target = if (!g_launch_btn_enabled)
        kLaunchDisabledColor
    else if (g_efmi_on_launch)
        ByteVec4{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }
    else
        ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };
    g_toggle_current_color = lerpColor(g_toggle_current_color, toggle_target, clamp01(dt * 12.0));
    g_efmi_current_color = lerpColor(g_efmi_current_color, efmi_target, clamp01(dt * 12.0));
    g_launch_current_color = lerpColor(g_launch_current_color, if (g_launch_btn_enabled) kLaunchEnabledColor else kLaunchDisabledColor, clamp01(dt * 12.0));

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
                moveWindowNoActivate(hwnd, g_window_anim.end_pos);
                g_window_anim.typ = .none;
            } else {
                const move_t = easeInOutCubic(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                _ = setWindowOpacityImmediate(easeOutQuad(t));
                moveWindowNoActivate(hwnd, .{ .x = g_window_anim.start_pos.x, .y = y });
            }
        },
        .slide_out_close => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                _ = setWindowOpacityImmediate(0.0);
                moveWindowNoActivate(hwnd, g_window_anim.end_pos);
                _ = c.DestroyWindow(hwnd);
                g_window_anim.typ = .none;
            } else {
                const move_t = easeInOutCubic(t);
                const fade_t = easeOutQuad(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                _ = setWindowOpacityImmediate(1.0 - fade_t);
                moveWindowNoActivate(hwnd, .{ .x = g_window_anim.start_pos.x, .y = y });
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

// Hit testing and hover state
fn pointInRoundedRectClient(pt: c.POINT) bool {
    return Ui.PointInCornerOnlyRoundedRect(
        .{ .x = pt.x, .y = pt.y },
        .{},
        platformWindowSize(),
        windowCornerRadiusPx(),
    );
}

fn getVersionRect() bgc.RECT {
    const font = if (g_font_version != null) g_font_version else g_font_textbox;
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

fn launchVisualLeftShift() f32 {
    return scaleF(6.0) * g_launch_anim.value;
}

fn launchVisualLeft() f32 {
    return scaleF(LAUNCH_X) - launchVisualLeftShift();
}

fn launchVisualHeight() f32 {
    return scaleF(LAUNCH_H) + scaleF(4.0) * g_launch_anim.value;
}

fn launchVisualPos() ByteVec2 {
    const h = launchVisualHeight();
    const cy = scaleF(LAUNCH_Y + LAUNCH_H * 0.5);
    return .{ .x = launchVisualLeft(), .y = cy - h * 0.5 };
}

fn launchVisualSize() ByteVec2 {
    return .{ .x = scaleF(LAUNCH_W) + scaleF(12.0) * g_launch_anim.value, .y = launchVisualHeight() };
}

fn launchVisualRounding() f32 {
    return scaleF(8.0) + scaleF(4.0) * g_launch_anim.value;
}

fn efmiVisibleWidth() f32 {
    return scaleF(EFMI_VISIBLE_W);
}

fn efmiLabelWidth() f32 {
    return efmiVisibleWidth();
}

fn efmiUnderlapWidth() f32 {
    return scaleF(EFMI_UNDERLAP_W);
}

fn efmiVisualLeft() f32 {
    return launchVisualLeft() - efmiVisibleWidth();
}

fn efmiLabelLeft() f32 {
    return efmiVisualLeft();
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

fn getEfmiRect(expanded_hit: bool) c.RECT {
    _ = expanded_hit;
    const anim = g_efmi_anim.value;
    const h = scaleF(EFMI_H) + scaleF(4.0) * anim;
    const cy = scaleF(EFMI_Y + EFMI_H * 0.5);
    return makeRectL(efmiVisualLeft(), cy - h * 0.5, efmiVisibleWidth(), h);
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
    close_hit.right = @intFromFloat(platformWindowSize().x);
}

fn hitTestButton(pt: c.POINT) i32 {
    var close_hit = std.mem.zeroes(bgc.RECT);
    var min_hit = std.mem.zeroes(bgc.RECT);
    getWindowControlHitRects(&min_hit, &close_hit);

    const info_hit = getInfoRect();
    const version_hit = getVersionRect();
    const launch_hit = getLaunchRect(false);
    const toggle_hit = getToggleRect(true);
    const efmi_hit = getEfmiRect(true);

    if (pointInRect(toggle_hit, pt)) return 6;
    if (pointInRect(close_hit, pt)) return 1;
    if (g_allow_minimize and pointInRect(min_hit, pt)) return 2;
    if (pointInRect(info_hit, pt)) return 3;
    if (pointInRect(version_hit, pt)) return 4;
    if (pointInRect(launch_hit, pt) and g_launch_btn_enabled) return 5;
    if (g_efmi_button_visible and g_launch_btn_enabled and pointInRect(efmi_hit, pt)) return 7;
    return 0;
}

fn outputTextRect() c.RECT {
    const y = if (g_logo_bounds.valid) g_logo_bounds.min.y else (WINDOW_HEIGHT - MAIN_CONTENT_SIZE) * 0.5;
    const h = if (g_logo_bounds.valid) g_logo_bounds.max.y - g_logo_bounds.min.y else MAIN_CONTENT_SIZE;
    const x = WINDOW_WIDTH * 0.5 + MAIN_CONTENT_CENTER_EDGE_OFFSET;

    return makeRectL(scaleF(x), scaleF(y), @max(1.0, scaleF(OUTPUT_W)), @max(1.0, scaleF(h)));
}

fn outputViewportSizeFromRect(rect: c.RECT) ByteVec2 {
    return .{
        .x = @max(1.0, @as(f32, @floatFromInt(rect.right - rect.left))),
        .y = @max(1.0, @as(f32, @floatFromInt(rect.bottom - rect.top))),
    };
}

fn pointInOutputTextRect(pt: c.POINT) bool {
    return pointInRect(outputTextRect(), pt);
}

fn outputMaxScrollFor(content_height: f32, viewport_height: f32) f32 {
    return @max(0.0, content_height - viewport_height);
}

fn clampOutputScrollTo(max_scroll: f32) void {
    g_output_scroll_y = std.math.clamp(g_output_scroll_y, 0.0, max_scroll);
}

fn buildOutputText(out: *std.ArrayListUnmanaged(u8)) bool {
    for (g_output_lines.items, 0..) |line, index| {
        out.appendSlice(allocator, line) catch return false;
        if (index + 1 < g_output_lines.items.len) out.append(allocator, '\n') catch return false;
    }
    return true;
}

fn layoutOutputText(text: []const u8) ?OutputTextLayout {
    const font = g_font_textbox orelse return null;
    const rect = outputTextRect();
    const viewport = outputViewportSizeFromRect(rect);
    var wrap_width = viewport.x;
    var layout = ByteGui.LayoutText(font, font.LegacySize, text, wrap_width) orelse return null;
    var overflow = layout.height > viewport.y + 0.5;

    if (overflow) {
        const reserved_w = scaleF(OUTPUT_SCROLLBAR_W + OUTPUT_SCROLLBAR_PAD * 2.0);
        const reduced_wrap_width = @max(1.0, viewport.x - reserved_w);
        if (reduced_wrap_width < wrap_width) {
            layout.deinit();
            wrap_width = reduced_wrap_width;
            layout = ByteGui.LayoutText(font, font.LegacySize, text, wrap_width) orelse return null;
            overflow = layout.height > viewport.y + 0.5;
        }
    }

    return .{
        .layout = layout,
        .viewport = viewport,
        .overflow = overflow,
    };
}

fn refreshOutputLayoutState() void {
    var text: std.ArrayListUnmanaged(u8) = .empty;
    defer text.deinit(allocator);
    if (!buildOutputText(&text)) return;

    var laid_out = layoutOutputText(text.items) orelse return;
    defer laid_out.deinit();
    g_output_content_height = laid_out.layout.height;
    clampOutputScrollTo(outputMaxScrollFor(g_output_content_height, laid_out.viewport.y));
}

fn outputScrollbarMetricsFor(content_height: f32, viewport_height: f32) ?bytegui.ScrollbarMetrics {
    const rect = outputTextRect();
    const width = scaleF(OUTPUT_SCROLLBAR_W);
    const pad = scaleF(OUTPUT_SCROLLBAR_PAD);
    return ByteGui.CalcVerticalScrollbarMetrics(.{
        .track_pos = .{
            .x = @as(f32, @floatFromInt(rect.right)) - pad - width,
            .y = @as(f32, @floatFromInt(rect.top)) + pad,
        },
        .track_size = .{ .x = width, .y = @max(1.0, viewport_height - pad * 2.0) },
        .content_height = content_height,
        .viewport_height = viewport_height,
        .scroll_y = g_output_scroll_y,
        .min_thumb_height = scaleF(OUTPUT_SCROLLBAR_MIN_H),
    });
}

fn currentOutputScrollbarMetrics() ?bytegui.ScrollbarMetrics {
    const rect = outputTextRect();
    const viewport = outputViewportSizeFromRect(rect);
    return outputScrollbarMetricsFor(g_output_content_height, viewport.y);
}

fn pointInOutputScrollbarThumb(pt: c.POINT) bool {
    const metrics = currentOutputScrollbarMetrics() orelse return false;
    const hit_pad = scaleF(3.0);
    return ByteGui.PointInScrollbarThumb(metrics, .{ .x = @floatFromInt(pt.x), .y = @floatFromInt(pt.y) }, hit_pad);
}

fn cursorInOutputScrollbarThumb(metrics: bytegui.ScrollbarMetrics) bool {
    const hwnd = g_hwnd orelse return false;
    var pt = std.mem.zeroes(c.POINT);
    if (c.GetCursorPos(&pt) == c.FALSE) return false;
    _ = c.ScreenToClient(hwnd, &pt);
    const hit_pad = scaleF(3.0);
    return ByteGui.PointInScrollbarThumb(metrics, .{ .x = @floatFromInt(pt.x), .y = @floatFromInt(pt.y) }, hit_pad);
}

fn setOutputScrollY(value: f32) void {
    const rect = outputTextRect();
    const viewport = outputViewportSizeFromRect(rect);
    g_output_pending_autoscroll = false;
    g_output_scroll_y = std.math.clamp(value, 0.0, outputMaxScrollFor(g_output_content_height, viewport.y));
}

fn scrollOutputBy(delta_y: f32) bool {
    refreshOutputLayoutState();
    const rect = outputTextRect();
    const viewport = outputViewportSizeFromRect(rect);
    const max_scroll = outputMaxScrollFor(g_output_content_height, viewport.y);
    if (max_scroll <= 0.5) return false;

    setOutputScrollY(g_output_scroll_y + delta_y);
    return true;
}

fn nextTextIndex(text: []const u8, index: usize, end: usize) usize {
    if (index >= end) return end;
    const cp_len = std.unicode.utf8ByteSequenceLength(text[index]) catch 1;
    return @min(end, index + cp_len);
}

fn outputTextWidth(text: []const u8, start: usize, end: usize) f32 {
    const font = g_font_textbox orelse return 0.0;
    if (end <= start) return 0.0;
    return ByteGui.CalcTextWidth(font, font.LegacySize, text[start..end]);
}

fn outputLineIndexAtX(text: []const u8, line: bytegui.TextLine, x: f32) usize {
    if (x <= 0.0 or line.end <= line.start) return line.start;
    if (x >= line.width) return line.end;

    var index = line.start;
    while (index < line.end) {
        const next = nextTextIndex(text, index, line.end);
        const left_w = outputTextWidth(text, line.start, index);
        const right_w = outputTextWidth(text, line.start, next);
        if (x < (left_w + right_w) * 0.5) return index;
        index = next;
    }
    return line.end;
}

fn outputIndexFromPointWithLayout(text: []const u8, layout: *const bytegui.TextLayoutResult, pt: c.POINT) usize {
    if (text.len == 0 or layout.lines.items.len == 0) return 0;

    const rect = outputTextRect();
    const x = @as(f32, @floatFromInt(pt.x - rect.left));
    const y = @as(f32, @floatFromInt(pt.y - rect.top)) + g_output_scroll_y;
    if (y <= 0.0) return outputLineIndexAtX(text, layout.lines.items[0], x);

    const line_height = @max(1.0, layout.line_height);
    const line_index_f = @floor(y / line_height);
    if (line_index_f >= @as(f32, @floatFromInt(layout.lines.items.len))) return text.len;

    const line_index: usize = @intFromFloat(@max(0.0, line_index_f));
    return outputLineIndexAtX(text, layout.lines.items[line_index], x);
}

fn outputIndexFromPoint(pt: c.POINT) usize {
    var text: std.ArrayListUnmanaged(u8) = .empty;
    defer text.deinit(allocator);
    if (!buildOutputText(&text)) return 0;

    var laid_out = layoutOutputText(text.items) orelse return text.items.len;
    defer laid_out.deinit();
    return outputIndexFromPointWithLayout(text.items, &laid_out.layout, pt);
}

fn clampOutputSelection(text_len: usize) void {
    if (g_output_selection_anchor) |anchor| g_output_selection_anchor = @min(anchor, text_len);
    g_output_selection_cursor = @min(g_output_selection_cursor, text_len);
}

fn outputSelectionRange(text_len: usize) ?OutputSelectionRange {
    const anchor = g_output_selection_anchor orelse return null;
    const cursor = g_output_selection_cursor;
    if (anchor == cursor) return null;
    return .{
        .start = @min(anchor, cursor),
        .end = @min(@max(anchor, cursor), text_len),
    };
}

fn selectedOutputTextAlloc() ?[]u8 {
    var text: std.ArrayListUnmanaged(u8) = .empty;
    defer text.deinit(allocator);
    if (!buildOutputText(&text)) return null;

    clampOutputSelection(text.items.len);
    const selection = outputSelectionRange(text.items.len) orelse return null;
    if (selection.end <= selection.start) return null;
    return allocator.dupe(u8, text.items[selection.start..selection.end]) catch null;
}

fn selectAllOutputText() void {
    var text: std.ArrayListUnmanaged(u8) = .empty;
    defer text.deinit(allocator);
    if (!buildOutputText(&text) or text.items.len == 0) {
        clearOutputSelection();
        return;
    }

    g_output_selection_anchor = 0;
    g_output_selection_cursor = text.items.len;
}

fn controlKeyDown() bool {
    return (@as(u16, @bitCast(c.GetAsyncKeyState(c.VK_CONTROL))) & 0x8000) != 0;
}

fn copyOutputSelectionToClipboard(hwnd: c.HWND) bool {
    const selected = selectedOutputTextAlloc() orelse return false;
    defer allocator.free(selected);

    const h_mem = c.GlobalAlloc(c.GMEM_MOVEABLE, (selected.len + 1) * @sizeOf(u16)) orelse return false;
    var transferred = false;
    defer {
        if (!transferred) _ = c.GlobalFree(h_mem);
    }

    const raw = c.GlobalLock(h_mem) orelse return false;
    const wide: [*]u16 = @ptrCast(@alignCast(raw));
    const wide_len = std.unicode.wtf8ToWtf16Le(wide[0..selected.len], selected) catch return false;
    wide[wide_len] = 0;
    _ = c.GlobalUnlock(h_mem);

    if (c.OpenClipboard(hwnd) == c.FALSE) return false;
    defer _ = c.CloseClipboard();
    if (c.EmptyClipboard() == c.FALSE) return false;
    if (c.SetClipboardData(c.CF_UNICODETEXT, h_mem) == null) return false;
    transferred = true;
    return true;
}

fn handleOutputKeyDown(hwnd: c.HWND, w_param: c.WPARAM) c.LRESULT {
    if (!controlKeyDown()) return -1;
    switch (w_param) {
        c.VK_A => {
            selectAllOutputText();
            return 0;
        },
        c.VK_C => {
            _ = copyOutputSelectionToClipboard(hwnd);
            return 0;
        },
        else => return -1,
    }
}

fn updateOutputSelectionAtPoint(pt: c.POINT) void {
    g_output_selection_cursor = outputIndexFromPoint(pt);
}

fn beginOutputMouseDown(hwnd: c.HWND, pt: c.POINT) bool {
    if (!pointInOutputTextRect(pt)) return false;

    applyHoveredButton(0);
    if (pointInOutputScrollbarThumb(pt)) {
        g_output_drag_mode = .scrollbar;
        g_output_scroll_drag_start_y = pt.y;
        g_output_scroll_drag_start_scroll = g_output_scroll_y;
    } else {
        const index = outputIndexFromPoint(pt);
        g_output_selection_anchor = index;
        g_output_selection_cursor = index;
        g_output_drag_mode = .select;
    }
    _ = c.SetCapture(hwnd);
    return true;
}

fn updateOutputScrollbarDrag(pt: c.POINT) void {
    const metrics = currentOutputScrollbarMetrics() orelse return;
    const dy = @as(f32, @floatFromInt(pt.y - g_output_scroll_drag_start_y));
    setOutputScrollY(ByteGui.ScrollbarDragScroll(metrics, g_output_scroll_drag_start_scroll, dy));
}

fn updateOutputDrag(pt: c.POINT) bool {
    switch (g_output_drag_mode) {
        .none => return false,
        .select => {
            const rect = outputTextRect();
            const line_step = if (g_font_textbox) |font| font.LegacySize else scaleF(13.0);
            if (pt.y < rect.top) {
                _ = scrollOutputBy(-line_step);
            } else if (pt.y >= rect.bottom) {
                _ = scrollOutputBy(line_step);
            }
            updateOutputSelectionAtPoint(pt);
            return true;
        },
        .scrollbar => {
            updateOutputScrollbarDrag(pt);
            return true;
        },
    }
}

fn finishOutputDrag() bool {
    if (g_output_drag_mode == .none) return false;
    g_output_drag_mode = .none;
    _ = c.ReleaseCapture();
    return true;
}

fn handleOutputMouseWheel(hwnd: c.HWND, w_param: c.WPARAM, l_param: c.LPARAM) c.LRESULT {
    var pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    _ = c.ScreenToClient(hwnd, &pt);
    if (!pointInRoundedRectClient(pt) or !pointInOutputTextRect(pt)) return -1;

    const delta = highWordSignedWParam(w_param);
    if (delta == 0) return 0;
    const line_step = if (g_font_textbox) |font| font.LegacySize * OUTPUT_WHEEL_LINES else scaleF(13.0) * OUTPUT_WHEEL_LINES;
    const steps = @as(f32, @floatFromInt(delta)) / @as(f32, @floatFromInt(WHEEL_DELTA));
    _ = scrollOutputBy(-steps * line_step);
    return 0;
}

fn applyHoveredButton(next_hover: i32) void {
    const prev_hover = g_hovered_button;
    if (prev_hover == next_hover) return;

    g_hovered_button = next_hover;
    if (prev_hover >= 1 and prev_hover <= 4) startButtonColorAnim(prev_hover, kControlIdleColor);
    if (g_hovered_button == 1) {
        startButtonColorAnim(1, .{ .x = 1.0, .y = 127.0 / 255.0, .z = 80.0 / 255.0, .w = 1.0 });
    } else if (g_hovered_button == 2) {
        startButtonColorAnim(2, .{ .x = 218.0 / 255.0, .y = 165.0 / 255.0, .z = 32.0 / 255.0, .w = 1.0 });
    } else if (g_hovered_button == 3 or g_hovered_button == 4) {
        startButtonColorAnim(g_hovered_button, kControlHoverBlue);
    }

    const launch_group_hovered = g_hovered_button == 5 or g_hovered_button == 7;
    startScalarAnim(&g_launch_anim, if (launch_group_hovered) 1.0 else 0.0, 0.18);
    startScalarAnim(&g_launch_label_anim, if (g_hovered_button == 5) 1.0 else 0.0, 0.18);
    startScalarAnim(&g_toggle_anim, if (g_hovered_button == 6) 1.0 else 0.0, 0.18);
    startScalarAnim(&g_efmi_anim, if (launch_group_hovered) 1.0 else 0.0, 0.18);
    startScalarAnim(&g_efmi_label_anim, if (g_hovered_button == 7) 1.0 else 0.0, 0.18);
}

fn beginMouseLeaveTracking(hwnd: c.HWND) void {
    if (g_mouse_leave_tracking) return;
    var track = c.TRACKMOUSEEVENT{
        .cbSize = @sizeOf(c.TRACKMOUSEEVENT),
        .dwFlags = c.TME_LEAVE,
        .hwndTrack = hwnd,
        .dwHoverTime = 0,
    };
    if (c.TrackMouseEvent(&track) != c.FALSE) g_mouse_leave_tracking = true;
}

fn cursorIdForClientPoint(pt: c.POINT) u16 {
    if (!pointInRoundedRectClient(pt)) return IDC_ARROW_ID;

    if (pointInOutputTextRect(pt) and !pointInOutputScrollbarThumb(pt)) return IDC_IBEAM_ID;

    const hit_id = hitTestButton(pt);
    if (hit_id == 5 or hit_id == 6 or hit_id == 7) return IDC_HAND_ID;

    return IDC_ARROW_ID;
}

fn applyCursorId(cursor_id: u16) void {
    _ = c.SetCursor(loadCursorResource(cursor_id));
}

fn applyCursorForClientPoint(pt: c.POINT) void {
    applyCursorId(cursorIdForClientPoint(pt));
}

fn applyDefaultCursor() void {
    applyCursorId(IDC_ARROW_ID);
}

fn clearWindowHoverState() void {
    g_cursor_in_window = false;
    g_mouse_leave_tracking = false;
    applyHoveredButton(0);
    applyDefaultCursor();
}

fn armHoverAfterCursorMotion() void {
    g_hover_requires_cursor_motion = true;
    g_last_cursor_screen_valid = c.GetCursorPos(&g_last_cursor_screen) != c.FALSE;
    clearWindowHoverState();
}

fn updateHoverStates(dt: f32) void {
    _ = dt;
    if (!g_cursor_in_window) applyHoveredButton(0);
}

fn yellowBandContactPointPx() ByteVec2 {
    if (g_logo_end_d_contact) |contact| return .{ .x = scaleF(contact.x), .y = scaleF(contact.y) };
    const bounds = if (g_logo_end_d_bounds.valid) g_logo_end_d_bounds else g_logo_bounds;
    if (bounds.valid) return .{ .x = scaleF(bounds.max.x), .y = scaleF(bounds.max.y) };
    return scaleVec2(WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5);
}

fn drawYellowRotatedRect(draw: ?*ByteDrawList, opacity: f32) void {
    const active_draw = draw orelse return;
    const window_size = platformWindowSize();
    const contact = yellowBandContactPointPx();
    const edge_axis = ByteVec2{ .x = 0.70710677, .y = -0.70710677 };
    const fill_axis = ByteVec2{ .x = 0.70710677, .y = 0.70710677 };
    const span = @sqrt(window_size.x * window_size.x + window_size.y * window_size.y);
    const thickness = @max(1.0, window_size.y - windowCornerRadiusPx() * 0.4);
    const contact_start = ByteVec2{ .x = contact.x - edge_axis.x * span, .y = contact.y - edge_axis.y * span };
    const contact_end = ByteVec2{ .x = contact.x + edge_axis.x * span, .y = contact.y + edge_axis.y * span };
    const edge_start = ByteVec2{ .x = contact_start.x - fill_axis.x * thickness, .y = contact_start.y - fill_axis.y * thickness };
    const edge_end = ByteVec2{ .x = contact_end.x - fill_axis.x * thickness, .y = contact_end.y - fill_axis.y * thickness };
    const subject = [_]ByteVec2{
        edge_start,
        edge_end,
        contact_end,
        contact_start,
    };
    const color = toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, opacity));
    ByteGui.DrawConvexPolyFilledClippedToCornerOnlyRoundedRect(
        active_draw,
        subject[0..],
        .{ .x = 0.0, .y = 0.0 },
        window_size,
        windowCornerRadiusPx(),
        color,
        std.math.clamp(scaleIF(6.0), 6, 20),
    );
}

fn buttonIsLaunch(id: []const u8) bool {
    return std.mem.eql(u8, id, "launch_btn");
}

fn buttonIsEfmi(id: []const u8) bool {
    return std.mem.eql(u8, id, "efmi_btn");
}

fn getButtonLabelTexture(id: []const u8) *const TextTexture {
    if (buttonIsLaunch(id)) return &g_launch_label_texture;
    return &g_toggle_label_texture;
}

fn drawAnimatedTextureLabel(draw: ?*ByteDrawList, texture: *const TextTexture, is_launch: bool, pos: ByteVec2, size: ByteVec2, anim: f32, opacity: f32) bool {
    const base_scale: f32 = if (is_launch) 0.94 else 0.92;
    return Ui.DrawAnimatedTextureCentered(
        draw,
        texture,
        pos,
        size,
        .{ .x = scaleF(if (is_launch) 6.0 else 1.0), .y = scaleF(if (is_launch) 4.0 else 0.25) },
        base_scale,
        base_scale + BUTTON_LABEL_HOVER_DELTA,
        anim,
        .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 },
        opacity,
    );
}

fn drawTextTextureCentered(draw: *ByteDrawList, texture: *const TextTexture, center: ByteVec2, scale: f32, opacity: f32) bool {
    if (texture.texture == null or texture.display_size_px.x <= 0.0 or texture.display_size_px.y <= 0.0) return false;

    const texture_size = if (texture.image_size_px.x > 0.0 and texture.image_size_px.y > 0.0) texture.image_size_px else texture.display_size_px;
    const content_size = ByteVec2{
        .x = texture.display_size_px.x * scale,
        .y = texture.display_size_px.y * scale,
    };
    const image_size = ByteVec2{
        .x = texture_size.x * scale,
        .y = texture_size.y * scale,
    };
    const content_pos = ByteVec2{
        .x = center.x - content_size.x * 0.5,
        .y = center.y - content_size.y * 0.5,
    };
    const image_pos = ByteVec2{
        .x = content_pos.x + texture.draw_offset_px.x * scale,
        .y = content_pos.y + texture.draw_offset_px.y * scale,
    };

    draw.AddImage(
        texture.texture,
        image_pos,
        .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y },
        texture.uv_min,
        texture.uv_max,
        toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity)),
    );
    return true;
}

fn drawEfmiButtonLabelTexture(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, anim: f32, opacity: f32) bool {
    const active_draw = draw orelse return false;
    const label_scale = 0.92 + 0.12 * clamp01(anim);
    const base_gap = @max(scaleF(8.0), (g_efmi_top_label_texture.display_size_px.y + g_efmi_bottom_label_texture.display_size_px.y) * 0.38);
    const center_gap = base_gap * label_scale;
    const center = ByteVec2{ .x = pos.x + size.x * 0.5, .y = pos.y + size.y * 0.5 };
    const top_ok = drawTextTextureCentered(active_draw, &g_efmi_top_label_texture, .{ .x = center.x, .y = center.y - center_gap * 0.5 }, label_scale, opacity);
    const bottom_ok = drawTextTextureCentered(active_draw, &g_efmi_bottom_label_texture, .{ .x = center.x, .y = center.y + center_gap * 0.5 }, label_scale, opacity);
    return top_ok and bottom_ok;
}

fn drawAnimatedButtonLabelTexture(draw: ?*ByteDrawList, id: []const u8, pos: ByteVec2, size: ByteVec2, anim: f32, opacity: f32) bool {
    const is_launch = buttonIsLaunch(id);
    if (is_launch) return drawAnimatedTextureLabel(draw, &g_launch_label_texture, true, pos, size, g_launch_label_anim.value, opacity);
    if (buttonIsEfmi(id)) return drawEfmiButtonLabelTexture(draw, pos, size, g_efmi_label_anim.value, opacity);
    const text_texture = getButtonLabelTexture(id);
    return drawAnimatedTextureLabel(draw, text_texture, is_launch, pos, size, anim, opacity);
}

fn drawAnimatedBoxButtonVisual(id: []const u8, _: []const u8, base_pos: ByteVec2, base_size: ByteVec2, anim: f32, enabled: bool, base_color: ByteVec4, opacity: f32) void {
    _ = enabled;
    const is_launch = buttonIsLaunch(id);
    const is_efmi = buttonIsEfmi(id);
    const is_launch_group = is_launch or is_efmi;
    const color = base_color;
    const rounding = if (is_launch_group) scaleF(8.0) + scaleF(4.0) * anim else scaleF(5.0) + scaleF(2.0) * anim;

    const draw = ByteGui.GetWindowDrawList() orelse return;
    const saved_flags = draw.Flags;
    draw.Flags |= bytegui.ByteDrawListFlags_AntiAliasedFill;

    if (is_efmi) {
        const h = base_size.y + scaleF(4.0) * anim;
        const y = base_pos.y + base_size.y * 0.5 - h * 0.5;
        const visual_pos = ByteVec2{ .x = efmiVisualLeft(), .y = y };
        const visual_size = ByteVec2{ .x = efmiVisibleWidth() + efmiUnderlapWidth(), .y = h };
        const label_pos = ByteVec2{ .x = efmiLabelLeft(), .y = y };
        const label_size = ByteVec2{ .x = efmiLabelWidth(), .y = h };
        Ui.DrawRoundedLeftEdgeShadowedRectFilled(draw, visual_pos, visual_size, rounding, color, darkerEfmiShadowColor(color), opacity, launchVisualPos(), launchVisualSize(), launchVisualRounding(), scaleF(EFMI_SHADOW_WIDTH), EFMI_SHADOW_STRENGTH);
        draw.Flags = saved_flags;
        _ = drawAnimatedButtonLabelTexture(draw, id, label_pos, label_size, anim, opacity);
        return;
    }

    const center = ByteVec2{ .x = base_pos.x + base_size.x * 0.5, .y = base_pos.y + base_size.y * 0.5 };
    const size = ByteVec2{ .x = base_size.x + scaleF(12.0) * anim, .y = base_size.y + (if (is_launch_group) scaleF(4.0) else scaleF(3.0)) * anim };
    const pos = ByteVec2{ .x = center.x - size.x * 0.5, .y = center.y - size.y * 0.5 };
    draw.AddRectFilled(pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, toU32(applyOpacity(color, opacity)), rounding);
    draw.Flags = saved_flags;
    _ = drawAnimatedButtonLabelTexture(draw, id, pos, size, anim, opacity);
}

fn drawLogoVisual(draw: ?*ByteDrawList, opacity: f32) void {
    var valid_layers: [LOGO_BASE_PATH_LAYERS.len]Ui.ParsedSvgLayer = undefined;
    var n_valid: usize = 0;
    for (g_logo_layers) |slot| {
        if (slot) |layer| {
            valid_layers[n_valid] = layer;
            n_valid += 1;
        }
    }
    if (n_valid == 0) return;
    const col = toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity));
    const ds = scaleF(1.0);
    Ui.DrawParsedSvgLayers(draw, valid_layers[0..n_valid], col, ds);
}

fn drawOutputScrollbar(draw: *ByteDrawList, laid_out: *const OutputTextLayout, opacity: f32, dt: f32) void {
    if (!laid_out.overflow) return;
    const metrics = outputScrollbarMetricsFor(laid_out.layout.height, laid_out.viewport.y) orelse return;
    ByteGui.DrawVerticalScrollbar(draw, &g_output_scrollbar_visual, .{
        .metrics = metrics,
        .idle_color = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.40 },
        .hover_color = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.55 },
        .active_color = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.75 },
        .hovered = cursorInOutputScrollbarThumb(metrics),
        .active = g_output_drag_mode == .scrollbar,
        .opacity = opacity,
        .dt = dt,
    });
}

fn drawDebugOutlineBounds(draw: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, color: ByteVec4, opacity: f32) void {
    const left = @floor(@min(p_min.x, p_max.x));
    const top = @floor(@min(p_min.y, p_max.y));
    const right = @ceil(@max(p_min.x, p_max.x));
    const bottom = @ceil(@max(p_min.y, p_max.y));
    if (right <= left or bottom <= top) return;

    const thickness = @max(1.0, scaleF(1.0));
    const col = toU32(applyOpacity(color, opacity));
    draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = right, .y = @min(bottom, top + thickness) }, col, 0.0);
    draw.AddRectFilled(.{ .x = left, .y = @max(top, bottom - thickness) }, .{ .x = right, .y = bottom }, col, 0.0);
    draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = @min(right, left + thickness), .y = bottom }, col, 0.0);
    draw.AddRectFilled(.{ .x = @max(left, right - thickness), .y = top }, .{ .x = right, .y = bottom }, col, 0.0);
}

fn drawDebugRectOutline(draw: *ByteDrawList, rect: anytype, color: ByteVec4, opacity: f32) void {
    drawDebugOutlineBounds(
        draw,
        .{ .x = @as(f32, @floatFromInt(rect.left)), .y = @as(f32, @floatFromInt(rect.top)) },
        .{ .x = @as(f32, @floatFromInt(rect.right)), .y = @as(f32, @floatFromInt(rect.bottom)) },
        color,
        opacity,
    );
}

fn drawDebugBoxOutline(draw: *ByteDrawList, pos: ByteVec2, size: ByteVec2, color: ByteVec4, opacity: f32) void {
    drawDebugOutlineBounds(draw, pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, color, opacity);
}

fn drawDebugGuideVertical(draw: *ByteDrawList, x: f32, y_min: f32, y_max: f32, color: ByteVec4, opacity: f32) void {
    const top = @floor(@min(y_min, y_max));
    const bottom = @ceil(@max(y_min, y_max));
    if (bottom <= top) return;
    const thickness = @max(1.0, scaleF(1.0));
    const left = @floor(x - thickness * 0.5);
    const col = toU32(applyOpacity(color, opacity));
    draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = left + thickness, .y = bottom }, col, 0.0);
}

fn drawDebugGuideHorizontal(draw: *ByteDrawList, y: f32, x_min: f32, x_max: f32, color: ByteVec4, opacity: f32) void {
    const left = @floor(@min(x_min, x_max));
    const right = @ceil(@max(x_min, x_max));
    if (right <= left) return;
    const thickness = @max(1.0, scaleF(1.0));
    const top = @floor(y - thickness * 0.5);
    const col = toU32(applyOpacity(color, opacity));
    draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = right, .y = top + thickness }, col, 0.0);
}

fn drawDebugCrosshair(draw: *ByteDrawList, center: ByteVec2, radius: f32, color: ByteVec4, opacity: f32) void {
    drawDebugGuideHorizontal(draw, center.y, center.x - radius, center.x + radius, color, opacity);
    drawDebugGuideVertical(draw, center.x, center.y - radius, center.y + radius, color, opacity);
}

fn drawDebugLineSegment(draw: *ByteDrawList, center: ByteVec2, axis: ByteVec2, length: f32, thickness: f32, color: ByteVec4, opacity: f32) void {
    const axis_len = @sqrt(axis.x * axis.x + axis.y * axis.y);
    if (axis_len <= 0.0 or length <= 0.0 or thickness <= 0.0) return;

    const dir = ByteVec2{ .x = axis.x / axis_len, .y = axis.y / axis_len };
    const normal = ByteVec2{ .x = -dir.y, .y = dir.x };
    const half_len = length * 0.5;
    const half_thick = thickness * 0.5;
    const p0 = ByteVec2{ .x = center.x - dir.x * half_len, .y = center.y - dir.y * half_len };
    const p1 = ByteVec2{ .x = center.x + dir.x * half_len, .y = center.y + dir.y * half_len };
    const points = [_]ByteVec2{
        .{ .x = p0.x + normal.x * half_thick, .y = p0.y + normal.y * half_thick },
        .{ .x = p1.x + normal.x * half_thick, .y = p1.y + normal.y * half_thick },
        .{ .x = p1.x - normal.x * half_thick, .y = p1.y - normal.y * half_thick },
        .{ .x = p0.x - normal.x * half_thick, .y = p0.y - normal.y * half_thick },
    };
    draw.AddConvexPolyFilled(&points, toU32(applyOpacity(color, opacity)));
}

fn drawDebugLogoDContactMarker(draw: *ByteDrawList, opacity: f32) void {
    const contact = yellowBandContactPointPx();
    const edge_axis = ByteVec2{ .x = 0.70710677, .y = -0.70710677 };
    const perp_axis = ByteVec2{ .x = 0.70710677, .y = 0.70710677 };
    const main_len = scaleF(24.0);
    const tick_len = main_len / 3.0;
    const thickness = @max(1.0, scaleF(1.0));

    drawDebugLineSegment(draw, contact, edge_axis, main_len, thickness, kDebugHitboxColor, opacity);
    drawDebugLineSegment(draw, contact, perp_axis, tick_len, thickness, kDebugHitboxColor, opacity);
}

fn drawDebugLayoutConstraintBounds(draw: *ByteDrawList, opacity: f32) void {
    const constraint_opacity = opacity * DEBUG_BOX_CONSTRAINT_OPACITY;
    const guide_opacity = opacity * DEBUG_BOX_GUIDE_OPACITY;

    const content_top = scaleF((WINDOW_HEIGHT - MAIN_CONTENT_SIZE) * 0.5);
    const content_height = scaleF(MAIN_CONTENT_SIZE);
    const content_bottom = content_top + content_height;
    const center_x = scaleF(WINDOW_WIDTH * 0.5);
    const center_y = scaleF(WINDOW_HEIGHT * 0.5);
    const logo_right = scaleF(WINDOW_WIDTH * 0.5 - MAIN_CONTENT_CENTER_EDGE_OFFSET);
    const text_left = scaleF(WINDOW_WIDTH * 0.5 + MAIN_CONTENT_CENTER_EDGE_OFFSET);
    const logo_slot_left = logo_right - scaleF(MAIN_CONTENT_SIZE);
    const text_slot_w = @max(1.0, scaleF(OUTPUT_W));

    // Main horizontal layout lane and center split/edge constraints
    drawDebugBoxOutline(draw, .{ .x = logo_slot_left, .y = content_top }, .{ .x = logo_right - logo_slot_left, .y = content_height }, kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, .{ .x = text_left, .y = content_top }, .{ .x = text_slot_w, .y = content_height }, kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugOutlineBounds(draw, .{ .x = logo_slot_left, .y = content_top }, .{ .x = text_left + text_slot_w, .y = content_bottom }, kDebugGuideLineColor, guide_opacity);
    drawDebugGuideVertical(draw, logo_right, content_top, content_bottom, kDebugConstraintBoundsColor, guide_opacity);
    drawDebugGuideVertical(draw, text_left, content_top, content_bottom, kDebugConstraintBoundsColor, guide_opacity);
    drawDebugGuideHorizontal(draw, content_top, logo_slot_left, text_left + text_slot_w, kDebugConstraintBoundsColor, guide_opacity);
    drawDebugGuideHorizontal(draw, content_bottom, logo_slot_left, text_left + text_slot_w, kDebugConstraintBoundsColor, guide_opacity);

    // Button/control base constraint boxes before expansion
    drawDebugBoxOutline(draw, scaleVec2(TOGGLE_X, TOGGLE_Y + TOGGLE_Y_OFFSET), scaleVec2(TOGGLE_W, TOGGLE_H), kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, scaleVec2(LAUNCH_X, LAUNCH_Y), scaleVec2(LAUNCH_W, LAUNCH_H), kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, scaleVec2(EFMI_X, EFMI_Y), scaleVec2(EFMI_W, EFMI_H), kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, scaleVec2(INFO_X, INFO_Y), scaleVec2(INFO_W, INFO_H), kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET), scaleVec2(MIN_W, MIN_H), kDebugConstraintBoundsColor, constraint_opacity);
    drawDebugBoxOutline(draw, scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET), scaleVec2(CLOSE_W, CLOSE_H), kDebugConstraintBoundsColor, constraint_opacity);

    drawDebugCrosshair(draw, snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y)), scaleF(4.0), kDebugConstraintBoundsColor, guide_opacity);
    drawDebugCrosshair(draw, .{ .x = center_x, .y = center_y }, scaleF(5.0), kDebugGuideLineColor, guide_opacity);
}

fn drawDebugWindowCenterGuides(draw: *ByteDrawList, opacity: f32) void {
    const platform_size = platformWindowSize();
    const design_size = scaleVec2(WINDOW_WIDTH, WINDOW_HEIGHT);
    const width = if (platform_size.x > 0.0) platform_size.x else design_size.x;
    const height = if (platform_size.y > 0.0) platform_size.y else design_size.y;
    if (width <= 0.0 or height <= 0.0) return;

    const center_x = @floor(width * 0.5);
    const center_y = @floor(height * 0.5);
    const center_opacity = @max(opacity, 0.85);

    drawDebugGuideVertical(draw, center_x, 0.0, height, kDebugCenterLineColor, center_opacity);
    drawDebugGuideHorizontal(draw, center_y, 0.0, width, kDebugCenterLineColor, center_opacity);
}

fn drawDebugLogoBounds(draw: *ByteDrawList, bounds: LogoBounds, color: ByteVec4, opacity: f32) void {
    if (!bounds.valid) return;
    drawDebugOutlineBounds(
        draw,
        .{ .x = scaleF(bounds.min.x), .y = scaleF(bounds.min.y) },
        .{ .x = scaleF(bounds.max.x), .y = scaleF(bounds.max.y) },
        color,
        opacity,
    );
}

fn drawDebugScrollbarBounds(draw: *ByteDrawList, opacity: f32) void {
    const metrics = currentOutputScrollbarMetrics() orelse return;
    const hit_pad = scaleF(3.0);

    drawDebugBoxOutline(draw, metrics.track_pos, metrics.track_size, kDebugScrollbarBoundsColor, opacity);
    drawDebugBoxOutline(draw, metrics.thumb_pos, metrics.thumb_size, kDebugScrollbarBoundsColor, opacity);
    drawDebugOutlineBounds(
        draw,
        .{ .x = metrics.thumb_pos.x - hit_pad, .y = metrics.thumb_pos.y - hit_pad },
        .{ .x = metrics.thumb_pos.x + metrics.thumb_size.x + hit_pad, .y = metrics.thumb_pos.y + metrics.thumb_size.y + hit_pad },
        kDebugHitboxColor,
        opacity,
    );
}

fn drawDebugBoxOverlay(draw: *ByteDrawList, opacity: f32) void {
    if (!g_debug_options.boxes) return;

    const debug_opacity = @min(opacity, DEBUG_BOX_OVERLAY_OPACITY);
    const window_size = platformWindowSize();
    drawDebugWindowCenterGuides(draw, debug_opacity);
    drawDebugLayoutConstraintBounds(draw, debug_opacity);
    drawDebugBoxOutline(draw, .{}, window_size, kDebugWindowBoundsColor, debug_opacity);

    drawDebugLogoBounds(draw, g_logo_bounds, kDebugLogoBoundsColor, debug_opacity);
    drawDebugLogoBounds(draw, g_logo_end_d_bounds, kDebugLogoBoundsColor, debug_opacity * 0.75);
    drawDebugLogoDContactMarker(draw, debug_opacity);

    drawDebugRectOutline(draw, outputTextRect(), kDebugTextBoundsColor, debug_opacity);
    drawDebugScrollbarBounds(draw, debug_opacity);

    var close_hit = std.mem.zeroes(bgc.RECT);
    var min_hit = std.mem.zeroes(bgc.RECT);
    getWindowControlHitRects(&min_hit, &close_hit);

    drawDebugRectOutline(draw, close_hit, kDebugHitboxColor, debug_opacity);
    drawDebugBoxOutline(draw, scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET), scaleVec2(CLOSE_W, CLOSE_H), kDebugVisualBoundsColor, debug_opacity);

    if (g_allow_minimize) {
        drawDebugRectOutline(draw, min_hit, kDebugHitboxColor, debug_opacity);
        drawDebugBoxOutline(draw, scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET), scaleVec2(MIN_W, MIN_H), kDebugVisualBoundsColor, debug_opacity);
    }

    drawDebugRectOutline(draw, getInfoRect(), kDebugHitboxColor, debug_opacity);
    drawDebugBoxOutline(draw, scaleVec2(INFO_X, INFO_Y), scaleVec2(INFO_W, INFO_H), kDebugVisualBoundsColor, debug_opacity);

    drawDebugRectOutline(draw, getVersionRect(), kDebugTextBoundsColor, debug_opacity);

    drawDebugRectOutline(draw, getToggleRect(true), kDebugHitboxColor, debug_opacity);
    drawDebugRectOutline(draw, getToggleRect(false), kDebugVisualBoundsColor, debug_opacity);

    if (g_launch_btn_enabled) drawDebugRectOutline(draw, getLaunchRect(false), kDebugHitboxColor, debug_opacity);
    drawDebugBoxOutline(draw, launchVisualPos(), launchVisualSize(), kDebugVisualBoundsColor, debug_opacity);

    if (g_efmi_button_visible) {
        if (g_launch_btn_enabled) drawDebugRectOutline(draw, getEfmiRect(true), kDebugHitboxColor, debug_opacity);
        const h = scaleF(EFMI_H) + scaleF(4.0) * g_efmi_anim.value;
        const cy = scaleF(EFMI_Y + EFMI_H * 0.5);
        drawDebugBoxOutline(
            draw,
            .{ .x = efmiVisualLeft(), .y = cy - h * 0.5 },
            .{ .x = efmiVisibleWidth() + efmiUnderlapWidth(), .y = h },
            kDebugVisualBoundsColor,
            debug_opacity,
        );
    }
}

fn drawOutputTextbox(draw: ?*ByteDrawList, opacity: f32, dt: f32) void {
    const active_draw = draw orelse return;
    const font = g_font_textbox orelse return;
    var text: std.ArrayListUnmanaged(u8) = .empty;
    defer text.deinit(allocator);
    if (!buildOutputText(&text)) return;

    clampOutputSelection(text.items.len);
    var laid_out = layoutOutputText(text.items) orelse return;
    defer laid_out.deinit();

    g_output_content_height = laid_out.layout.height;
    const max_scroll = outputMaxScrollFor(g_output_content_height, laid_out.viewport.y);
    if (g_output_pending_autoscroll) {
        g_output_scroll_y = max_scroll;
        g_output_pending_autoscroll = false;
    } else {
        clampOutputScrollTo(max_scroll);
    }

    const rect = outputTextRect();
    const base_x = @as(f32, @floatFromInt(rect.left));
    const base_y = @as(f32, @floatFromInt(rect.top));
    const bottom = @as(f32, @floatFromInt(rect.bottom));
    const line_height = @max(1.0, laid_out.layout.line_height);
    const saved_clip = active_draw.CurrentClipRect;
    active_draw.SetClipRect(.{
        .x = @as(f32, @floatFromInt(rect.left)),
        .y = @as(f32, @floatFromInt(rect.top)),
        .z = @as(f32, @floatFromInt(rect.right)),
        .w = @as(f32, @floatFromInt(rect.bottom)),
    });

    const selection = if (outputSelectionRange(text.items.len)) |range|
        bytegui.TextSelectionRange{ .start = range.start, .end = range.end }
    else
        null;
    ByteGui.DrawTextSelectionHighlight(active_draw, &g_output_selection_highlight, .{
        .font = font,
        .font_size = font.LegacySize,
        .text = text.items,
        .layout = &laid_out.layout,
        .selection = selection,
        .base_pos = .{ .x = base_x, .y = base_y },
        .viewport_height = @as(f32, @floatFromInt(rect.bottom - rect.top)),
        .scroll_y = g_output_scroll_y,
        .color = .{ .x = 0.15, .y = 0.38, .z = 1.0, .w = 0.25 },
        .opacity = opacity,
        .radius = scaleF(2.0),
        .dt = dt,
    });

    const text_col = toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity));
    for (laid_out.layout.lines.items, 0..) |line, line_index| {
        const y = base_y + @as(f32, @floatFromInt(line_index)) * line_height - g_output_scroll_y;
        if (y + line_height < base_y or y > bottom) continue;
        active_draw.AddText(font, font.LegacySize, .{ .x = base_x, .y = y }, text_col, text.items[line.start..line.end], null);
    }

    active_draw.SetClipRect(saved_clip);
    drawOutputScrollbar(active_draw, &laid_out, opacity, dt);
}

fn drawUI(dt: f32) void {
    const render_opacity: f32 = 1.0;
    const window_size = platformWindowSize();
    ByteGui.SetNextWindowPos(.{});
    ByteGui.SetNextWindowSize(window_size);

    const flags: u32 = ByteGuiWindowFlags_NoDecoration | ByteGuiWindowFlags_NoMove | ByteGuiWindowFlags_NoResize | ByteGuiWindowFlags_NoSavedSettings | ByteGuiWindowFlags_NoNav | ByteGuiWindowFlags_NoBackground;
    _ = ByteGui.Begin("##root", null, flags);
    defer ByteGui.End();

    const draw = ByteGui.GetWindowDrawList() orelse return;
    ByteGui.DrawCornerOnlyRoundedRectFilled(draw, .{}, window_size, windowCornerRadiusPx(), toU32(applyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(6.0), 6, 20));
    drawYellowRotatedRect(draw, render_opacity);

    ByteGui.DrawInfoGlyph(draw, scaleVec2(INFO_X, INFO_Y), scaleVec2(INFO_W, INFO_H), toU32(applyOpacity(g_button_colors[3].current, render_opacity)), toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(72.0), 72, 160));
    if (g_allow_minimize) ByteGui.DrawWindowControlGlyph(draw, scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET), scaleVec2(MIN_W, MIN_H), toU32(applyOpacity(g_button_colors[2].current, render_opacity)), false);
    ByteGui.DrawWindowControlGlyph(draw, scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET), scaleVec2(CLOSE_W, CLOSE_H), toU32(applyOpacity(g_button_colors[1].current, render_opacity)), true);
    drawLogoVisual(draw, render_opacity);

    drawOutputTextbox(draw, render_opacity, dt);

    draw.AddText(g_font_version, scaleF(12.0), snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y)), toU32(applyOpacity(g_button_colors[4].current, render_opacity)), g_version_display, null);
    drawAnimatedBoxButtonVisual("toggle_btn", toggleButtonLabel(), scaleVec2(TOGGLE_X, TOGGLE_Y + TOGGLE_Y_OFFSET), scaleVec2(TOGGLE_W, TOGGLE_H), g_toggle_anim.value, true, g_toggle_current_color, render_opacity);
    if (g_efmi_button_visible) drawAnimatedBoxButtonVisual("efmi_btn", LABEL_EFMI, scaleVec2(EFMI_X, EFMI_Y), scaleVec2(EFMI_W, EFMI_H), g_efmi_anim.value, true, g_efmi_current_color, render_opacity);
    drawAnimatedBoxButtonVisual("launch_btn", LABEL_LAUNCH, scaleVec2(LAUNCH_X, LAUNCH_Y), scaleVec2(LAUNCH_W, LAUNCH_H), g_launch_anim.value, g_launch_btn_enabled, g_launch_current_color, render_opacity);
    drawDebugBoxOverlay(draw, render_opacity);
}

fn refreshGamePathStatus() void {
    if (g_game_exe_path) |path| allocator.free(path);
    g_game_exe_path = loader.resolveGameExe(g_game_exe_override_path, g_environ, allocator) catch null;
    g_startup_target_pid = loader.findTargetProcess();
    setLoaderTargetRunning(g_startup_target_pid != 0);
    syncLaunchButtonStateImmediate();
}

fn maybeRestoreAfterExit() void {
    const hwnd = g_hwnd orelse return;
    if (!g_minimized_by_toggle and !g_stayed_open_by_toggle) return;
    cancelCloseCountdown();
    clearStatusLines();
    if (g_minimized_by_toggle and c.IsIconic(hwnd) != c.FALSE) {
        _ = c.ShowWindow(hwnd, c.SW_RESTORE);
        bringWindowToFront();
    }
    appendStatus(strings.status_ready_for_injection_again, .{});
    g_minimized_by_toggle = false;
    g_stayed_open_by_toggle = false;
}

fn resetLaunchRightClickSequence() void {
    g_launch_right_click_count = 0;
    g_launch_right_click_last_tick = 0;
}

fn registerLaunchRightClick() bool {
    const now = c.GetTickCount64();
    const threshold: u64 = @max(1, @as(u64, @intCast(c.GetDoubleClickTime())));
    if (g_launch_right_click_last_tick == 0 or now - g_launch_right_click_last_tick > threshold) {
        g_launch_right_click_count = 0;
    }

    g_launch_right_click_last_tick = now;
    if (g_launch_right_click_count < 3) g_launch_right_click_count += 1;
    if (g_launch_right_click_count < 3) return false;

    resetLaunchRightClickSequence();
    return true;
}

fn launchGameAction(requested_mode: GameLaunchMode) void {
    resetLaunchRightClickSequence();
    cancelCloseCountdown();
    const mode = selectedLaunchMode(requested_mode);
    if (!g_launch_btn_enabled) {
        setLoaderPendingLaunchMode(null);
        appendStatus(strings.status_launch_requested_unavailable, .{});
        return;
    }

    setLoaderPendingLaunchMode(mode);
    const launch_result: loader.LaunchError!void = switch (mode) {
        .normal => blk: {
            const game_path = g_game_exe_path orelse {
                setLoaderPendingLaunchMode(null);
                appendStatus(strings.status_launch_requested_unavailable, .{});
                return;
            };
            startLaunchCooldown(mode);
            break :blk loader.launchGame(game_path);
        },
        .dx11 => blk: {
            const game_path = g_game_exe_path orelse {
                setLoaderPendingLaunchMode(null);
                appendStatus(strings.status_launch_requested_unavailable, .{});
                return;
            };
            startLaunchCooldown(mode);
            break :blk loader.launchGameWithArgs(game_path, loader.game_dx11_arg);
        },
        .efmi => blk: {
            const efmi_path = g_efmi_launcher_path orelse {
                setLoaderPendingLaunchMode(null);
                appendStatus(strings.status_efmi_missing_path, .{});
                return;
            };
            startLaunchCooldown(mode);
            break :blk cli.launchEfmiLauncher(efmi_path);
        },
    };
    launch_result catch |err| {
        setLoaderPendingLaunchMode(null);
        switch (mode) {
            .normal, .dx11 => appendStatus(strings.status_launch_failed_fmt, .{loader.describeLaunchError(err)}),
            .efmi => appendStatus(strings.status_efmi_launch_failed_fmt, .{strings.describeEfmiLaunchError(err)}),
        }
        return;
    };

    setLoaderTargetRunning(true);
    updateLaunchButtonState();
    appendLaunchModeStatus(mode);
}

// External actions
fn openReadme() void {
    _ = c.ShellExecuteW(null, SHELL_OPEN_OPERATION, README_URL, null, null, c.SW_SHOWNORMAL);
}

fn openReleaseTag() void {
    var version_buf: [32]u8 = undefined;
    const normalized = app_version.normalizedTag(&version_buf, VERSION_STR) catch return;

    var url_utf8_buf: [160]u8 = undefined;
    const url_utf8 = std.fmt.bufPrint(
        &url_utf8_buf,
        RELEASE_URL_FMT,
        .{normalized},
    ) catch return;

    var url_utf16_buf: [160]u16 = undefined;
    const url_utf16 = wtf8ToWtf16LeZ(url_utf8, &url_utf16_buf) catch return;
    _ = c.ShellExecuteW(null, SHELL_OPEN_OPERATION, url_utf16.ptr, null, null, c.SW_SHOWNORMAL);
}

// Input and window procedure
fn onButtonActivated(id: i32) void {
    switch (id) {
        1 => if (g_window_anim.typ == .none) startWindowAnimation(.slide_out_close),
        2 => if (g_allow_minimize and g_window_anim.typ == .none) startWindowAnimation(.fade_out_minimize),
        3 => openReadme(),
        4 => openReleaseTag(),
        5 => launchGameAction(defaultLaunchMode()),
        6 => setLoaderMinimizeOnLaunch(!g_minimize_on_launch),
        7 => if (g_launch_btn_enabled) setEfmiOnLaunch(!g_efmi_on_launch),
        else => {},
    }
}

fn handleLButtonDown(hwnd: c.HWND, l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    if (!pointInRoundedRectClient(pt)) return 0;
    clearOutputSelection();

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
            7 => getEfmiRect(true),
            else => std.mem.zeroes(c.RECT),
        };

        _ = c.SetCapture(hwnd);
        return 0;
    }

    if (beginOutputMouseDown(hwnd, pt)) return 0;

    g_dragging = true;
    g_drag_offset = .{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    _ = c.SetCapture(hwnd);
    return 0;
}

fn handleMouseMove(hwnd: c.HWND, l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    applyCursorForClientPoint(pt);

    var screen_pt = std.mem.zeroes(c.POINT);
    const has_screen_pt = c.GetCursorPos(&screen_pt) != c.FALSE;
    const cursor_moved = !g_last_cursor_screen_valid or !has_screen_pt or screen_pt.x != g_last_cursor_screen.x or screen_pt.y != g_last_cursor_screen.y;
    if (has_screen_pt) {
        g_last_cursor_screen = screen_pt;
        g_last_cursor_screen_valid = true;
    } else {
        g_last_cursor_screen_valid = false;
    }
    if (cursor_moved) g_hover_requires_cursor_motion = false;
    if (updateOutputDrag(pt)) return 0;
    if (g_hover_requires_cursor_motion and !g_dragging and !g_press_captured) return 0;

    if (pointInRoundedRectClient(pt)) {
        g_cursor_in_window = true;
        beginMouseLeaveTracking(hwnd);
        if (!g_dragging and !g_press_captured) applyHoveredButton(hitTestButton(pt));
    } else {
        clearWindowHoverState();
    }

    if (g_dragging) {
        var cur = std.mem.zeroes(c.POINT);
        _ = c.GetCursorPos(&cur);
        moveWindowNoActivate(hwnd, .{ .x = cur.x - g_drag_offset.x, .y = cur.y - g_drag_offset.y });
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

fn handleMouseLeave() c.LRESULT {
    clearWindowHoverState();
    applyDefaultCursor();
    return 0;
}

fn handleLButtonUp(l_param: c.LPARAM) c.LRESULT {
    if (finishOutputDrag()) return 0;

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

fn handleRButtonDown(l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    if (!pointInRoundedRectClient(pt)) {
        resetLaunchRightClickSequence();
        return -1;
    }
    clearOutputSelection();

    if (hitTestButton(pt) == 5) return 0;

    resetLaunchRightClickSequence();
    return -1;
}

fn handleRButtonUp(l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    if (!pointInRoundedRectClient(pt)) {
        resetLaunchRightClickSequence();
        return -1;
    }

    if (hitTestButton(pt) != 5) {
        resetLaunchRightClickSequence();
        return -1;
    }

    if (registerLaunchRightClick()) launchGameAction(alternateLaunchMode());
    return 0;
}

fn wndProc(hwnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.winapi) c.LRESULT {
    const active_hwnd = hwnd;

    if (msg == c.WM_NCHITTEST) {
        var pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
        _ = c.ScreenToClient(active_hwnd, &pt);
        if (!pointInRoundedRectClient(pt)) return c.HTTRANSPARENT;
        return c.HTCLIENT;
    }

    switch (msg) {
        c.WM_SETCURSOR => {
            if (lowWordU(l_param) == 1) {
                var pt = std.mem.zeroes(c.POINT);
                if (c.GetCursorPos(&pt) != c.FALSE) {
                    _ = c.ScreenToClient(active_hwnd, &pt);
                    applyCursorForClientPoint(pt);
                } else {
                    applyDefaultCursor();
                }
                return 1;
            }

            applyDefaultCursor();
            return 1;
        },
        c.WM_LBUTTONDOWN => return handleLButtonDown(active_hwnd, l_param),
        c.WM_MOUSEMOVE => {
            const result = handleMouseMove(active_hwnd, l_param);
            if (result != -1) return result;
        },
        c.WM_MOUSELEAVE => return handleMouseLeave(),
        c.WM_LBUTTONUP => {
            const result = handleLButtonUp(l_param);
            if (result != -1) return result;
        },
        c.WM_RBUTTONDOWN => {
            const result = handleRButtonDown(l_param);
            if (result != -1) return result;
        },
        c.WM_RBUTTONUP => {
            const result = handleRButtonUp(l_param);
            if (result != -1) return result;
        },
        c.WM_MOUSEWHEEL => {
            const result = handleOutputMouseWheel(active_hwnd, w_param, l_param);
            if (result != -1) return result;
        },
        c.WM_KEYDOWN => {
            const result = handleOutputKeyDown(active_hwnd, w_param);
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

// Startup and shutdown
fn appendInitialStatusLines() void {
    if (g_startup_target_pid != 0) {
        if (g_game_exe_path != null) appendStatus(strings.status_game_found, .{});
        appendStatus(strings.status_game_already_running_startup, .{});
    } else if (g_game_exe_path != null) {
        appendStatus(strings.status_game_found, .{});
        appendStatus(strings.status_launch_here_or_external, .{});
    } else {
        appendStatus(strings.status_game_not_found, .{});
        appendStatus(strings.status_launch_externally, .{});
    }
}

fn resetButtonColorAnimations() void {
    for (g_button_colors[1..5]) |*color_anim| {
        color_anim.current = kControlIdleColor;
        color_anim.start = kControlIdleColor;
        color_anim.target = kControlIdleColor;
    }
}

fn initByteGuiIo() void {
    const io = ByteGui.GetIO();
    io.IniFilename = null;
    io.LogFilename = null;
    io.DisplaySize = platformWindowSize();
}

fn initGuiResources(platform_hwnd: ?bgc.HWND) void {
    applyBaseStyle();
    loadFonts();
    _ = bytegui.ByteGui_ImplWin32_Init(platform_hwnd);
}

fn initializeGuiState() void {
    refreshEfmiAvailability();
    refreshGamePathStatus();
    appendInitialStatusLines();
    if (!startLoaderWorker()) appendStatus(strings.status_monitor_failed, .{});
    resetButtonColorAnimations();
    clearWindowHoverState();
}

fn prewarmVisibleTextCaches() void {
    if (g_font_version) |font| {
        _ = ByteGui.PrewarmTextTexture(font, scaleF(12.0), 0.0, g_version_display);
    }
    if (g_font_textbox) |font| {
        var text: std.ArrayListUnmanaged(u8) = .empty;
        defer text.deinit(allocator);
        if (!buildOutputText(&text)) return;

        var laid_out = layoutOutputText(text.items) orelse return;
        defer laid_out.deinit();
        for (laid_out.layout.lines.items) |line| _ = ByteGui.PrewarmTextTexture(font, font.LegacySize, 0.0, text.items[line.start..line.end]);
    }
}

noinline fn initGuiApp(instance: ?c.HMODULE) bool {
    bytegui.BYTEGUI_CHECKVERSION();
    _ = ByteGui.CreateContext() orelse return false;

    var window_config = ByteGuiPlatformWindowConfig{};
    window_config.Instance = if (instance) |handle| @ptrFromInt(@intFromPtr(handle)) else null;
    window_config.WndProc = wndProcBridge;
    window_config.ClassName = WINDOW_CLASS;
    window_config.Title = APP_TITLE;
    if (windowUsesLayeredOpacity()) window_config.ExStyle |= c.WS_EX_LAYERED;
    window_config.IconResourceId = APP_ICON_RESOURCE_ID;
    window_config.LogicalWidth = WINDOW_WIDTH;
    window_config.LogicalHeight = WINDOW_HEIGHT;

    if (!bytegui.ByteGui_ImplWin32_CreatePlatformWindow(&window_config)) return false;
    const platform_hwnd = bytegui.ByteGui_ImplWin32_GetPlatformHwnd();
    g_hwnd = fromByteGuiHwnd(platform_hwnd);
    if (!initLayeredWindowOpacity()) return false;
    initByteGuiIo();
    initGuiResources(platform_hwnd);

    var prepared_assets = StartupPreparedAssets{};
    var asset_thread: ?std.Thread = std.Thread.spawn(.{}, startupAssetWorkerMain, .{&prepared_assets}) catch null;
    errdefer {
        if (asset_thread) |thread| thread.join();
        prepared_assets.deinit();
    }

    const window_size = platformWindowSize();
    if (!bytegui.ByteGui_ImplOpenGL_Init(platform_hwnd, @intFromFloat(window_size.x), @intFromFloat(window_size.y))) return false;
    initializeGuiState();
    if (asset_thread) |thread| {
        thread.join();
        asset_thread = null;
    } else {
        prepareStartupAssets(&prepared_assets);
    }
    if (!uploadPreparedStartupAssets(&prepared_assets)) return false;
    rebuildLogoLayers();
    prepared_assets.deinit();
    prewarmVisibleTextCaches();

    applyWindowShape();
    showStartupWindow();
    return true;
}

fn shutdownGuiApp() void {
    stopLoaderWorker();
    clearLoaderEvents();
    bytegui.ByteGui_ImplOpenGL_Shutdown();
    bytegui.ByteGui_ImplWin32_Shutdown();
    cleanupRenderResources();
    clearDetectedEfmiLauncherPath();
    if (g_hwnd != null) bytegui.ByteGui_ImplWin32_DestroyPlatformWindow();
    if (ByteGui.GetCurrentContext() != null) ByteGui.DestroyContext(null);
    if (g_game_exe_path) |path| allocator.free(path);
    clearStatusLines();
}

fn runGui() !u8 {
    g_version_display = try computeVersionDisplay(&g_version_display_buf);
    if (!initGuiApp(c.GetModuleHandleA(null))) {
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
        updateLaunchButtonState();
        updateHoverStates(dt);
        updateAnimations(dt);
        if (!g_running or g_hwnd == null) break;

        bytegui.ByteGui_ImplOpenGL_NewFrame();
        bytegui.ByteGui_ImplWin32_NewFrame();
        ByteGui.NewFrame();
        drawUI(dt);
        ByteGui.Render();

        const clear_color = [4]f32{ 0, 0, 0, 0 };
        _ = bytegui.ByteGui_ImplOpenGL_BeginFrame(&clear_color);
        bytegui.ByteGui_ImplOpenGL_RenderDrawData(ByteGui.GetDrawData());
        _ = bytegui.ByteGui_ImplOpenGL_Present();
        c.Sleep(1);
    }
    return 0;
}

pub fn main(init: std.process.Init.Minimal) void {
    g_environ = init.environ;
    const config = cli.parseLaunchConfig(allocator, init.environ, init.args) catch |err| {
        switch (err) {
            error.OutOfMemory => cli.showArgumentError(strings.cli.parse_oom),
            error.MissingForceWineModeValue => cli.showArgumentError(cli.describeParseArgsError(error.MissingForceWineModeValue)),
            error.InvalidForceWineModeValue => cli.showArgumentError(cli.describeParseArgsError(error.InvalidForceWineModeValue)),
            error.MissingAllowMinimizeValue => cli.showArgumentError(cli.describeParseArgsError(error.MissingAllowMinimizeValue)),
            error.InvalidAllowMinimizeValue => cli.showArgumentError(cli.describeParseArgsError(error.InvalidAllowMinimizeValue)),
            error.MissingGamePathValue => cli.showArgumentError(cli.describeParseArgsError(error.MissingGamePathValue)),
            error.InvalidGamePathValue => cli.showArgumentError(cli.describeParseArgsError(error.InvalidGamePathValue)),
            error.MissingDebugValue => cli.showArgumentError(cli.describeParseArgsError(error.MissingDebugValue)),
            error.InvalidDebugValue => cli.showArgumentError(cli.describeParseArgsError(error.InvalidDebugValue)),
            error.MutuallyExclusiveDx11AndEfmi => cli.showArgumentError(cli.describeParseArgsError(error.MutuallyExclusiveDx11AndEfmi)),
            error.MutuallyExclusiveGamePathAndEfmi => cli.showArgumentError(cli.describeParseArgsError(error.MutuallyExclusiveGamePathAndEfmi)),
            error.MutuallyExclusiveAutoYesAndGui => cli.showArgumentError(cli.describeParseArgsError(error.MutuallyExclusiveAutoYesAndGui)),
            error.MutuallyExclusiveCliAndGuiArgs => cli.showArgumentError(cli.describeParseArgsError(error.MutuallyExclusiveCliAndGuiArgs)),
        }
        std.process.exit(1);
    };
    defer if (config.efmi_launcher_path) |path| allocator.free(path);
    defer if (config.game_exe_override_path) |path| allocator.free(path);

    g_game_exe_override_path = config.game_exe_override_path;
    g_efmi_requested = config.efmi_requested;
    g_efmi_search_enabled = config.efmi_search_enabled;
    g_efmi_launcher_path = config.efmi_launcher_path;
    g_efmi_on_launch = config.efmi_requested and config.efmi_search_enabled;
    g_force_dx11 = config.dx11;
    g_wine_mode = if (config.cli) false else resolveWineMode(config);
    g_allow_minimize = if (config.cli) true else resolveAllowMinimize(config, g_wine_mode);
    g_debug_options = config.debug;

    const code = if (config.cli)
        cli.run(allocator, init.environ, if (config.silent) .silent else .visible, embedded_dll, config) catch 1
    else blk: {
        break :blk runGui() catch 1;
    };
    std.process.exit(code);
}
