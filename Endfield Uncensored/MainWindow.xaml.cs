using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Media;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace UnGate11
{
    public partial class MainWindow : Window, IDisposable
    {
        // Constants
        private const int INVALID_CLICK_THRESHOLD = 3;
        private const string TARGET_EXE = "Endfield.exe";
        private const string DLL_NAME = "EFU.dll";

        // Fields
        private DispatcherTimer _delayTimer;
        private CancellationTokenSource _injectorCts;
        private string _tempDllPath;
        private string _tempDirectory;

        // State management
        private bool _interactionEnabled = true;
        private int _invalidClickCount = 0;
        private bool _disposed = false;

        // Cached storyboards
        private Storyboard _fadeLogoIn, _fadeLogoOut;

        // Constructor and Initialization
        public MainWindow()
        {
            InitializeComponent();
            CacheStoryboards();
            InitializeVersionLabel();

            // Extract DLL immediately at startup (before any delays)
            ExtractEmbeddedDll();

            StateChanged += MainWindow_StateChanged;
            Loaded += MainWindow_Loaded;
        }

        private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            // Start injection immediately - no delay
            await StartInjectorAsync();
        }

        private void CacheStoryboards()
        {
            _fadeLogoIn = (Storyboard)FindResource("FadeLogoIn");
            _fadeLogoOut = (Storyboard)FindResource("FadeLogoOut");
        }

        private void InitializeVersionLabel()
        {
            var version = GetVersion();
            string versionText = version.Revision > 0 
                ? $"PREVIEW v{version.Major}.{version.Minor}.{version.Build}.{version.Revision}"
                : $"v{version.Major}.{version.Minor}.{version.Build}";
            VersionLabel.Content = versionText;
            
            // Store version for URL navigation
            VersionLabel.Tag = $"v{version.Major}.{version.Minor}.{version.Build}" + (version.Revision > 0 ? $".{version.Revision}" : "");
        }

        // Interaction Management
        private void SetInteractionEnabled(bool state)
        {
            _interactionEnabled = state;

            // Visual disabled hint
            double visualOpacity = state ? 1.0 : 0.6;

            // Optionally change cursor to indicate disabled state
            Cursor = state ? Cursors.Arrow : Cursors.Wait;
        }

        // Window Animation Event Handlers
        private void CloseWindow(object sender, MouseButtonEventArgs e)
        {
            // Right-click to force close
            if (e.ChangedButton == MouseButton.Left && !_interactionEnabled)
            {
                HandleInvalidCloseClick();
                return;
            }

            // Get native top converted to WPF DIPs and apply optional tweak
            double currentTopDip = GetNativeWindowTop();

            // Clear any existing animation hold and set base value to the true visual top
            this.BeginAnimation(Window.TopProperty, null);
            this.Top = currentTopDip;

            // Clone storyboard and anchor the Top animation to the current DIP position
            var storyboardResource = (Storyboard)FindResource("SlideOutWindow");
            var sb = storyboardResource.Clone();

            foreach (var child in sb.Children)
            {
                if (child is DoubleAnimation da)
                {
                    var prop = Storyboard.GetTargetProperty(da);
                    string path = prop != null ? prop.Path : string.Empty;
                    if (path.Contains("Top") || path.Contains("(Window.Top)"))
                    {
                        da.From = currentTopDip;
                        da.To = currentTopDip + 50; // same movement as XAML; change if desired
                        da.By = null;
                        break;
                    }
                }
            }

            sb.Completed += (s, args) => Application.Current.Shutdown();
            sb.Begin(this);
        }

        /// <summary>
        /// Triggers the close animation programmatically (used for auto-close after successful injection)
        /// </summary>
        private void TriggerCloseAnimation()
        {
            // Get native top converted to WPF DIPs
            double currentTopDip = GetNativeWindowTop();

            // Clear any existing animation hold and set base value to the true visual top
            this.BeginAnimation(Window.TopProperty, null);
            this.Top = currentTopDip;

            // Clone storyboard and anchor the Top animation to the current DIP position
            var storyboardResource = (Storyboard)FindResource("SlideOutWindow");
            var sb = storyboardResource.Clone();

            foreach (var child in sb.Children)
            {
                if (child is DoubleAnimation da)
                {
                    var prop = Storyboard.GetTargetProperty(da);
                    string path = prop != null ? prop.Path : string.Empty;
                    if (path.Contains("Top") || path.Contains("(Window.Top)"))
                    {
                        da.From = currentTopDip;
                        da.To = currentTopDip + 50;
                        da.By = null;
                        break;
                    }
                }
            }

            sb.Completed += (s, args) => Application.Current.Shutdown();
            sb.Begin(this);
        }

        [global::System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [global::System.Runtime.InteropServices.StructLayout(global::System.Runtime.InteropServices.LayoutKind.Sequential)]
        private struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        private double GetNativeWindowTop()
        {
            var helper = new System.Windows.Interop.WindowInteropHelper(this);
            var hWnd = helper.Handle;
            if (hWnd == IntPtr.Zero)
                return this.Top;

            if (GetWindowRect(hWnd, out RECT rect))
            {
                // Convert physical pixels to WPF device-independent units (DIPs)
                var source = PresentationSource.FromVisual(this);
                if (source?.CompositionTarget != null)
                {
                    var transform = source.CompositionTarget.TransformFromDevice;
                    var topDip = transform.Transform(new System.Windows.Point(rect.Left, rect.Top)).Y;
                    return topDip;
                }

                // fallback (assume 1:1)
                return rect.Top;
            }

            return this.Top;
        }

        private void HandleInvalidButtonClick(ContentControl button)
        {
            _invalidClickCount++;
            PlayErrorSound();

            // Start XAML wiggle storyboard targeted at the clicked button's TranslateTransform
            try
            {
                var wiggleRes = (Storyboard)FindResource("WiggleButton");
                var wiggle = wiggleRes.Clone();

                // Ensure any previous translate animation is cleared so we start from the real value
                button.BeginAnimation(TranslateTransform.XProperty, null);

                // Assign target for each child timeline to the clicked button
                foreach (Timeline child in wiggle.Children)
                    Storyboard.SetTarget(child, button);

                // Begin the animation (FillBehavior.Stop in XAML ensures no persistent value)
                wiggle.Begin(this, true);
            }
            catch
            {
                // ignore resource failures; sound still played
            }

            if (_invalidClickCount >= INVALID_CLICK_THRESHOLD)
            {
                MessageBox.Show("You can't do that right now. Please wait until the current task is finished.", "Wait", MessageBoxButton.OK, MessageBoxImage.Warning);
                _invalidClickCount = 0;
            }
        }

        private void HandleInvalidCloseClick()
        {
            _invalidClickCount++;
            PlayErrorSound();
            WiggleWindow();
            if (_invalidClickCount >= INVALID_CLICK_THRESHOLD)
            {
                MessageBox.Show("You can't close the window right now. Please wait until current task is finished.\nIf you really want to close it anyway, right-click the close button.", "Wait", MessageBoxButton.OK, MessageBoxImage.Warning);
                _invalidClickCount = 0;
            }
        }

        private void WiggleWindow()
        {
            // Prevent any running animations from changing window geometry while we animate.
            this.BeginAnimation(Window.LeftProperty, null);
            this.BeginAnimation(Window.TopProperty, null);

            // Capture native/top position in DIPs (same approach used in CloseWindow) to avoid OS/WPF re-centering.
            double currentTopDip = GetNativeWindowTop();
            this.Top = currentTopDip;

            double originalLeft = this.Left;

            var wiggle = new DoubleAnimationUsingKeyFrames
            {
                Duration = TimeSpan.FromMilliseconds(400),
                FillBehavior = FillBehavior.Stop // don't hold the animated value after completion
            };

            // Keyframes around the current Left value for a smooth wiggle
            wiggle.KeyFrames.Add(new EasingDoubleKeyFrame(originalLeft, KeyTime.FromPercent(0.0)));
            wiggle.KeyFrames.Add(new EasingDoubleKeyFrame(originalLeft - 10, KeyTime.FromPercent(0.2))
            {
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            });
            wiggle.KeyFrames.Add(new EasingDoubleKeyFrame(originalLeft + 10, KeyTime.FromPercent(0.4))
            {
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            });
            wiggle.KeyFrames.Add(new EasingDoubleKeyFrame(originalLeft - 7, KeyTime.FromPercent(0.6))
            {
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            });
            wiggle.KeyFrames.Add(new EasingDoubleKeyFrame(originalLeft, KeyTime.FromPercent(1.0))
            {
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            });

            Storyboard.SetTarget(wiggle, this);
            Storyboard.SetTargetProperty(wiggle, new PropertyPath("(Window.Left)"));

            var sb = new Storyboard();
            sb.Children.Add(wiggle);

            // Restore exact original coordinates (Top + Left) when done to avoid rounding/OS adjustments.
            sb.Completed += (s, e) =>
            {
                this.BeginAnimation(Window.LeftProperty, null);
                this.BeginAnimation(Window.TopProperty, null);
                this.Left = originalLeft;
                this.Top = currentTopDip;
            };

            sb.Begin(this);
        }

        private void MainWindow_StateChanged(object sender, EventArgs e)
        {
            if (WindowState == WindowState.Normal)
            {
                var fadeInStoryboard = (Storyboard)FindResource("FadeInWindow");
                fadeInStoryboard.Begin(this);
            }
        }

        private void MinimizeWindow(object sender, MouseButtonEventArgs e)
        {
            var storyboard = (Storyboard)FindResource("FadeOutWindow");
            storyboard.Completed += (s, args) =>
            {
                WindowState = WindowState.Minimized;
                Opacity = 1;
            };
            storyboard.Begin(this);
        }

        private void Info(object sender, MouseButtonEventArgs e) => Process.Start(new ProcessStartInfo
        {
            FileName = "https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md",
            UseShellExecute = true
        });

        private void VersionLabel_Click(object sender, MouseButtonEventArgs e)
        {
            string version = VersionLabel.Tag?.ToString() ?? "v1.0.0";
            Process.Start(new ProcessStartInfo { FileName = $"https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/{version}" });
        }

        private void DragWindow(object sender, MouseButtonEventArgs e) => DragMove();

        private void PlayErrorSound() => SystemSounds.Hand.Play();

        private Version GetVersion() => Assembly.GetExecutingAssembly().GetName().Version;

        // ============================================================================
        // DLL INJECTION - Win32 API P/Invoke Declarations
        // ============================================================================

        #region Win32 API

        // Native loader DLL imports - injection done by native code to bypass anti-cheat
        [DllImport("loader.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        private static extern uint FindTargetProcess(string name);

        [DllImport("loader.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        private static extern bool InjectDll(uint pid, string dllPath);

        // Set DLL search directory so loader.dll can be found in temp directory
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetDllDirectory(string lpPathName);

        #endregion

        // ============================================================================
        // DLL INJECTION - Helper Methods
        // ============================================================================

        private string ExtractEmbeddedDll()
        {
            try
            {
                var assembly = Assembly.GetExecutingAssembly();
                
                // Create a unique temp directory for this session
                _tempDirectory = Path.Combine(Path.GetTempPath(), "EndfieldUncensored_" + Guid.NewGuid().ToString("N").Substring(0, 8));
                Directory.CreateDirectory(_tempDirectory);

                // Extract EFU.dll
                var dllResource = "Endfield_Uncensored.EFU.dll";
                using (Stream stream = assembly.GetManifestResourceStream(dllResource))
                {
                    if (stream != null)
                    {
                        string dllPath = Path.Combine(_tempDirectory, DLL_NAME);
                        using (FileStream fs = File.Create(dllPath))
                        {
                            stream.CopyTo(fs);
                        }
                        _tempDllPath = dllPath;
                    }
                }

                // Extract loader.dll (native injection library)
                var loaderResource = "Endfield_Uncensored.loader.dll";
                using (Stream stream = assembly.GetManifestResourceStream(loaderResource))
                {
                    if (stream != null)
                    {
                        string loaderPath = Path.Combine(_tempDirectory, "loader.dll");
                        using (FileStream fs = File.Create(loaderPath))
                        {
                            stream.CopyTo(fs);
                        }
                    }
                }

                // Set DLL search directory so P/Invoke can find loader.dll
                SetDllDirectory(_tempDirectory);

                return _tempDllPath;
            }
            catch
            {
                return null;
            }
        }

        private bool IsAdmin()
        {
            try
            {
                using (WindowsIdentity identity = WindowsIdentity.GetCurrent())
                {
                    WindowsPrincipal principal = new WindowsPrincipal(identity);
                    return principal.IsInRole(WindowsBuiltInRole.Administrator);
                }
            }
            catch
            {
                return false;
            }
        }

        private async Task StartInjectorAsync()
        {
            _injectorCts = new CancellationTokenSource();

            // Use a dedicated high-priority thread for injection
            var injectorThread = new Thread(InjectorThreadProc)
            {
                Priority = ThreadPriority.Highest,
                IsBackground = true
            };
            injectorThread.Start();

            // Wait for completion without blocking UI
            await Task.Run(() => injectorThread.Join(), _injectorCts.Token);
        }

        private void InjectorThreadProc()
        {
            try
            {
                if (!IsAdmin())
                {
                    AppendOutput("ERROR: Not running as administrator!");
                    return;
                }

                if (string.IsNullOrEmpty(_tempDllPath) || !File.Exists(_tempDllPath))
                {
                    AppendOutput($"ERROR: {DLL_NAME} not found!");
                    return;
                }

                AppendOutput($"Waiting for {TARGET_EXE}...");

                uint pid;
                while ((pid = FindTargetProcess(TARGET_EXE)) == 0)
                {
                    Thread.Sleep(100);
                }

                AppendOutput($"Process found (PID: {pid})");

                Thread.Sleep(10);

                AppendOutput("Attempting injection...");

                if (InjectDll(pid, _tempDllPath))
                {
                    AppendOutput("[OK] Injection successful!");
                    
                    // 5 second countdown before auto-close
                    for (int i = 5; i > 0; i--)
                    {
                        AppendOutput($"Closing in {i}...");
                        Thread.Sleep(1000);
                    }
                    
                    Dispatcher.Invoke(() => TriggerCloseAnimation());
                }
                else
                {
                    AppendOutput("[FAIL] Injection failed.");
                }
            }
            catch (Exception ex)
            {
                AppendOutput($"Exception: {ex.Message}");
            }
        }

        private void AppendOutput(string text)
        {
            Dispatcher.Invoke(() =>
            {
                // Find OutputTextBox in XAML (will be added in next step)
                if (FindName("OutputTextBox") is System.Windows.Controls.TextBox textBox)
                {
                    textBox.AppendText(text + "\n");
                    textBox.ScrollToEnd();
                }
            });
        }

        // IDisposable Implementation
        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    // Dispose managed resources
                    if (_delayTimer != null)
                    {
                        _delayTimer.Stop();
                        _delayTimer = null;
                    }

                    if (_injectorCts != null)
                    {
                        _injectorCts.Cancel();
                        _injectorCts.Dispose();
                        _injectorCts = null;
                    }
                }

                // Clean up temp directory (unmanaged cleanup - attempt even if not disposing)
                try
                {
                    if (!string.IsNullOrEmpty(_tempDirectory) && Directory.Exists(_tempDirectory))
                    {
                        Directory.Delete(_tempDirectory, true);
                    }
                }
                catch
                {
                    // Ignore cleanup errors - temp files will be cleaned by OS eventually
                }

                _disposed = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
