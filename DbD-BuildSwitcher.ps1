Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class DpiHelper {
        [DllImport("shcore.dll")]
        public static extern int SetProcessDpiAwareness(int awareness);
    }
"@
    [void][DpiHelper]::SetProcessDpiAwareness(2)
} catch {
    try {
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class DpiHelperFallback {
            [DllImport("user32.dll")]
            public static extern bool SetProcessDPIAware();
        }
"@
        [void][DpiHelperFallback]::SetProcessDPIAware()
    } catch { }
}
function Get-DefaultSteamPath {
    try {
        $reg = Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -Name 'SteamPath' -ErrorAction Stop
        return ($reg.SteamPath -replace '/', '\')
    } catch {
        return "C:\Program Files (x86)\Steam"
    }
}
$script:steamPath = Get-DefaultSteamPath
function Get-Paths {
    $steam = $script:steamPath.TrimEnd('\')
    [PSCustomObject]@{
        SteamPath      = $steam
        SteamExe       = Join-Path $steam "steam.exe"
        ManifestActive = Join-Path $steam "steamapps\appmanifest_381210.acf"
        ManifestLive   = Join-Path $steam "steamapps\appmanifest_381210 - Live.acf"
        ManifestPTB    = Join-Path $steam "steamapps\appmanifest_381210 - PTB.acf"
        FolderActive   = Join-Path $steam "steamapps\common\Dead by Daylight"
        FolderLive     = Join-Path $steam "steamapps\common\Dead by Daylight - Live"
        FolderPTB      = Join-Path $steam "steamapps\common\Dead by Daylight - PTB"
    }
}
function Wait-Ms([int]$ms) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt $ms) {
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
            [System.Windows.Threading.DispatcherPriority]::Background,
            [Action]{ }
        )
        Start-Sleep -Milliseconds 50
    }
}
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="DbD Build Switcher"
    Width="440" Height="540"
    MinWidth="420" MinHeight="520"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanMinimize"
    Background="#FF0C0C10"
    Foreground="White"
    FontFamily="Segoe UI"
    FontSize="11"
    UseLayoutRounding="True"
    SnapsToDevicePixels="True">
    <Window.Resources>
        <Color x:Key="BgDeep">#FF0C0C10</Color>
        <Color x:Key="BgPanel">#FF16161E</Color>
        <Color x:Key="BgInput">#FF121218</Color>
        <Color x:Key="BgBrowse">#FF262632</Color>
        <Color x:Key="BgBrowseHov">#FF373748</Color>
        <Color x:Key="Border">#FF28283A</Color>
        <Color x:Key="Accent">#FFDC1E5A</Color>
        <Color x:Key="AccentBright">#FFFF3273</Color>
        <Color x:Key="AccentDark">#FFAA1446</Color>
        <Color x:Key="LiveGreen">#FF00D26A</Color>
        <Color x:Key="PTBOrange">#FFFF9100</Color>
        <Color x:Key="WarnYellow">#FFFFC107</Color>
        <Color x:Key="ErrorRed">#FFFF3246</Color>
        <Color x:Key="TextMuted">#FF78788E</Color>
        <Color x:Key="TextSecondary">#FFAAAABE</Color>
        <Color x:Key="LogBg">#FF0A0A0E</Color>
        <SolidColorBrush x:Key="BgDeepBrush" Color="{StaticResource BgDeep}"/>
        <SolidColorBrush x:Key="BgPanelBrush" Color="{StaticResource BgPanel}"/>
        <SolidColorBrush x:Key="BgInputBrush" Color="{StaticResource BgInput}"/>
        <SolidColorBrush x:Key="BgBrowseBrush" Color="{StaticResource BgBrowse}"/>
        <SolidColorBrush x:Key="BorderBrush" Color="{StaticResource Border}"/>
        <SolidColorBrush x:Key="AccentBrush" Color="{StaticResource Accent}"/>
        <SolidColorBrush x:Key="AccentBrightBrush" Color="{StaticResource AccentBright}"/>
        <SolidColorBrush x:Key="TextMutedBrush" Color="{StaticResource TextMuted}"/>
        <SolidColorBrush x:Key="TextSecondaryBrush" Color="{StaticResource TextSecondary}"/>
        <SolidColorBrush x:Key="LogBgBrush" Color="{StaticResource LogBg}"/>
        <Style x:Key="BrowseButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource BgBrowseBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryBrush}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                CornerRadius="5"
                                Padding="0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background">
                                    <Setter.Value>
                                        <SolidColorBrush Color="{StaticResource BgBrowseHov}"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="{StaticResource BorderBrush}"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Background" Value="{StaticResource BgPanelBrush}"/>
                                <Setter Property="Foreground" Value="{StaticResource TextMutedBrush}"/>
                                <Setter Property="Cursor" Value="Arrow"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="ToggleButtonStyle" TargetType="Button">
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontFamily" Value="Segoe UI Semibold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" CornerRadius="8" Padding="0" Height="38">
                            <Border.Background>
                                <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                    <GradientStop Color="{StaticResource Accent}" Offset="0"/>
                                    <GradientStop Color="{StaticResource AccentDark}" Offset="1"/>
                                </LinearGradientBrush>
                            </Border.Background>
                            <Border.Effect>
                                <DropShadowEffect Color="{StaticResource Accent}" BlurRadius="20" ShadowDepth="0" Opacity="0.35"/>
                            </Border.Effect>
                            <Grid>
                                <Border CornerRadius="8" BorderThickness="0,1,0,0" Opacity="0.15">
                                    <Border.BorderBrush>
                                        <SolidColorBrush Color="White"/>
                                    </Border.BorderBrush>
                                </Border>
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background">
                                    <Setter.Value>
                                        <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                            <GradientStop Color="{StaticResource AccentBright}" Offset="0"/>
                                            <GradientStop Color="{StaticResource Accent}" Offset="1"/>
                                        </LinearGradientBrush>
                                    </Setter.Value>
                                </Setter>
                                <Setter TargetName="border" Property="Effect">
                                    <Setter.Value>
                                        <DropShadowEffect Color="{StaticResource AccentBright}" BlurRadius="30" ShadowDepth="0" Opacity="0.5"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background">
                                    <Setter.Value>
                                        <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                            <GradientStop Color="{StaticResource AccentDark}" Offset="0"/>
                                            <GradientStop Color="#FF8A0E38" Offset="1"/>
                                        </LinearGradientBrush>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Background" Value="{StaticResource BgPanelBrush}"/>
                                <Setter TargetName="border" Property="Effect" Value="{x:Null}"/>
                                <Setter Property="Foreground" Value="{StaticResource TextMutedBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="6"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Track x:Name="PART_Track" IsDirectionReversed="True">
                            <Track.Thumb>
                                <Thumb>
                                    <Thumb.Style>
                                        <Style TargetType="Thumb">
                                            <Setter Property="Template">
                                                <Setter.Value>
                                                    <ControlTemplate TargetType="Thumb">
                                                        <Border Background="#33FFFFFF" CornerRadius="3" Margin="0,2"/>
                                                    </ControlTemplate>
                                                </Setter.Value>
                                            </Setter>
                                        </Style>
                                    </Thumb.Style>
                                </Thumb>
                            </Track.Thumb>
                        </Track>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="AccentProgressBar" TargetType="ProgressBar">
            <Setter Property="Height" Value="4"/>
            <Setter Property="Background" Value="{StaticResource BgPanelBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource AccentBrush}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="IsIndeterminate" Value="False"/>
            <Setter Property="Visibility" Value="Collapsed"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Grid>
                            <Border x:Name="PART_Track" Background="{TemplateBinding Background}" CornerRadius="2"/>
                            <Border x:Name="PART_Indicator" Background="{TemplateBinding Foreground}" CornerRadius="2" HorizontalAlignment="Left"/>
                            <Canvas x:Name="indeterminateCanvas" ClipToBounds="True" Visibility="Collapsed">
                                <Border x:Name="indeterminateMark" Width="140" Height="4" CornerRadius="2">
                                    <Border.Background>
                                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                            <GradientStop Color="{StaticResource AccentDark}" Offset="0"/>
                                            <GradientStop Color="{StaticResource AccentBright}" Offset="0.5"/>
                                            <GradientStop Color="{StaticResource AccentDark}" Offset="1"/>
                                        </LinearGradientBrush>
                                    </Border.Background>
                                </Border>
                            </Canvas>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsIndeterminate" Value="True">
                                <Setter TargetName="PART_Indicator" Property="Visibility" Value="Collapsed"/>
                                <Setter TargetName="indeterminateCanvas" Property="Visibility" Value="Visible"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="0">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Height="3">
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="{StaticResource Accent}" Offset="0"/>
                    <GradientStop Color="{StaticResource AccentBright}" Offset="0.5"/>
                    <GradientStop Color="{StaticResource Accent}" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>
        </Border>
        <Grid Grid.Row="1" Margin="18,8,18,6">
            <StackPanel HorizontalAlignment="Left">
                <Image x:Name="imgLogo" Height="52" HorizontalAlignment="Left"
                       Stretch="Uniform" Visibility="Collapsed"/>
                <TextBlock x:Name="txtTitle"
                           Text="Dead by Daylight"
                           FontSize="15" FontWeight="Bold"
                           Foreground="White"/>
                <TextBlock Text="BUILD SWITCHER"
                           FontSize="8" FontWeight="Bold"
                           Foreground="{StaticResource TextMutedBrush}"
                           Margin="2,1,0,0"/>
            </StackPanel>
            <Button x:Name="btnSetup"
                    Content="&#x2699;"
                    HorizontalAlignment="Right" VerticalAlignment="Top"
                    Width="28" Height="28" Margin="0,2,0,0"
                    FontSize="15"
                    Style="{StaticResource BrowseButtonStyle}"
                    ToolTip="Setup Guide - configure Live &amp; PTB builds"/>
        </Grid>
        <Border Grid.Row="2" Height="1" Margin="18,0" Background="{StaticResource BorderBrush}"/>
        <Border Grid.Row="3" Margin="18,8,18,0" CornerRadius="6" Padding="12,8"
                BorderBrush="{StaticResource BorderBrush}" BorderThickness="1"
                Background="{StaticResource BgPanelBrush}">
            <Border.Effect>
                <DropShadowEffect Color="Black" BlurRadius="8" ShadowDepth="1" Opacity="0.2"/>
            </Border.Effect>
            <StackPanel>
                <TextBlock Text="CURRENT BUILD"
                           FontSize="8" FontWeight="Bold"
                           Foreground="{StaticResource TextMutedBrush}"/>
                <TextBlock x:Name="lblStatus"
                           Text="● Detecting..."
                           FontSize="18" FontWeight="Bold"
                           Foreground="{StaticResource TextSecondaryBrush}"
                           Margin="0,2,0,0"/>
                <Border x:Name="statusGlow" Margin="0,6,0,0" Height="2" CornerRadius="1"
                        Opacity="0.5">
                    <Border.Background>
                        <SolidColorBrush x:Name="statusGlowBrush" Color="{StaticResource TextMuted}"/>
                    </Border.Background>
                </Border>
            </StackPanel>
        </Border>
        <StackPanel Grid.Row="4" Margin="18,8,18,0">
            <TextBlock Text="STEAM INSTALLATION"
                       FontSize="8" FontWeight="Bold"
                       Foreground="{StaticResource TextMutedBrush}"
                       Margin="0,0,0,4"/>
            <Border CornerRadius="5" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1"
                    Background="{StaticResource BgInputBrush}" Height="30">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBox x:Name="txtSteamPath"
                             Grid.Column="0"
                             Background="Transparent"
                             Foreground="White"
                             BorderThickness="0"
                             FontSize="11"
                             VerticalContentAlignment="Center"
                             Padding="8,0,4,0"
                             CaretBrush="White"/>
                    <Button x:Name="btnBrowse"
                            Grid.Column="1"
                            Content="..."
                            Width="36" Margin="2"
                            Style="{StaticResource BrowseButtonStyle}"
                            ToolTip="Browse for Steam folder"/>
                </Grid>
            </Border>
        </StackPanel>
        <Button x:Name="btnToggle"
                Grid.Row="5"
                Content="Switch Build"
                Margin="18,8,18,0"
                Style="{StaticResource ToggleButtonStyle}"
                ToolTip="Closes Steam, swaps builds, reopens Steam"/>
        <ProgressBar x:Name="progressBar"
                     Grid.Row="6"
                     Margin="18,6,18,0"
                     Style="{StaticResource AccentProgressBar}"/>
        <Border Grid.Row="7" Height="1" Margin="18,6,18,0" Background="{StaticResource BorderBrush}"/>
        <DockPanel Grid.Row="8" Margin="18,6,18,0">
            <TextBlock DockPanel.Dock="Top"
                       Text="ACTIVITY LOG"
                       FontSize="8" FontWeight="Bold"
                       Foreground="{StaticResource TextMutedBrush}"
                       Margin="0,0,0,4"/>
            <Border CornerRadius="5" BorderBrush="{StaticResource BorderBrush}" BorderThickness="1"
                    Background="{StaticResource LogBgBrush}">
                <RichTextBox x:Name="rtbLog"
                             Background="Transparent"
                             Foreground="White"
                             BorderThickness="0"
                             IsReadOnly="True"
                             VerticalScrollBarVisibility="Auto"
                             FontFamily="Cascadia Code, Consolas"
                             FontSize="10"
                             Padding="6,4"
                             IsDocumentEnabled="True">
                    <RichTextBox.Document>
                        <FlowDocument/>
                    </RichTextBox.Document>
                </RichTextBox>
            </Border>
        </DockPanel>
        <TextBlock Grid.Row="9"
                   Text="v3.1  |  Live / PTB switcher for Dead by Daylight"
                   FontSize="8"
                   Foreground="{StaticResource TextMutedBrush}"
                   Margin="18,4,18,8"/>
        <Border x:Name="setupOverlay" Grid.Row="0" Grid.RowSpan="10"
                Background="#CC0C0C10" Visibility="Collapsed">
            <Border CornerRadius="8" MaxWidth="380"
                    VerticalAlignment="Center" HorizontalAlignment="Center"
                    Margin="20"
                    BorderBrush="{StaticResource BorderBrush}" BorderThickness="1"
                    Background="{StaticResource BgPanelBrush}"
                    Padding="20">
                <Border.Effect>
                    <DropShadowEffect Color="Black" BlurRadius="30" ShadowDepth="2" Opacity="0.5"/>
                </Border.Effect>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBlock x:Name="setupStepLabel" Grid.Row="0"
                               Text="STEP 1 OF 4"
                               FontSize="8" FontWeight="Bold"
                               Foreground="{StaticResource AccentBrightBrush}"
                               Margin="0,0,0,4"/>
                    <TextBlock x:Name="setupTitle" Grid.Row="1"
                               Text="Which build is installed?"
                               FontSize="14" FontWeight="Bold"
                               Foreground="White"
                               TextWrapping="Wrap"
                               Margin="0,0,0,10"/>
                    <StackPanel x:Name="setupContent" Grid.Row="2">
                        <StackPanel x:Name="setupStep1" Visibility="Visible">
                            <TextBlock Text="Select which build is currently installed as 'Dead by Daylight' in your Steam library:"
                                       FontSize="11" Foreground="{StaticResource TextSecondaryBrush}"
                                       TextWrapping="Wrap" Margin="0,0,0,12"/>
                            <RadioButton x:Name="rbLive" Content="  Live (standard release)"
                                         Foreground="White" FontSize="12"
                                         IsChecked="True" Margin="0,0,0,8"/>
                            <RadioButton x:Name="rbPTB" Content="  PTB (Public Test Build)"
                                         Foreground="White" FontSize="12"
                                         Margin="0,0,0,4"/>
                        </StackPanel>
                        <StackPanel x:Name="setupStep2" Visibility="Collapsed">
                            <TextBlock x:Name="setupStep2Text"
                                       Text="Copying your current build files..."
                                       FontSize="11" Foreground="{StaticResource TextSecondaryBrush}"
                                       TextWrapping="Wrap" Margin="0,0,0,8"/>
                            <TextBlock x:Name="setupStep2Detail"
                                       Text="This may take several minutes for large installs. Check the activity log for progress."
                                       FontSize="10" Foreground="{StaticResource TextMutedBrush}"
                                       TextWrapping="Wrap"/>
                        </StackPanel>
                        <StackPanel x:Name="setupStep3" Visibility="Collapsed">
                            <TextBlock x:Name="setupStep3Text"
                                       Text="Now install the other build via Steam:"
                                       FontSize="11" Foreground="{StaticResource TextSecondaryBrush}"
                                       TextWrapping="Wrap" Margin="0,0,0,8"/>
                            <Border CornerRadius="4" Background="{StaticResource BgDeepBrush}"
                                    Padding="10,8" Margin="0,0,0,8">
                                <StackPanel>
                                    <TextBlock Text="1. Start Steam (it was closed for the copy)." Foreground="White" FontSize="10" TextWrapping="Wrap" Margin="0,0,0,3"/>
                                    <TextBlock Text="2. Right-click Dead by Daylight &#x2192; Properties." Foreground="White" FontSize="10" TextWrapping="Wrap" Margin="0,0,0,3"/>
                                    <TextBlock Text="3. Go to the Betas tab." Foreground="White" FontSize="10" TextWrapping="Wrap" Margin="0,0,0,3"/>
                                    <TextBlock x:Name="setupStep3Branch" Text="4. Select the 'public-test' branch." Foreground="{StaticResource AccentBrightBrush}" FontSize="10" FontWeight="SemiBold" TextWrapping="Wrap" Margin="0,0,0,3"/>
                                    <TextBlock Text="5. Let the download complete fully." Foreground="White" FontSize="10" TextWrapping="Wrap"/>
                                </StackPanel>
                            </Border>
                            <TextBlock Text="Click 'Verify Setup' once the download is complete."
                                       FontSize="10" Foreground="{StaticResource TextMutedBrush}"
                                       TextWrapping="Wrap"/>
                        </StackPanel>
                        <StackPanel x:Name="setupStep4" Visibility="Collapsed">
                            <TextBlock x:Name="setupStep4Text"
                                       Text="Verifying your setup..."
                                       FontSize="11" Foreground="{StaticResource TextSecondaryBrush}"
                                       TextWrapping="Wrap" Margin="0,0,0,8"/>
                            <TextBlock x:Name="setupStep4Detail"
                                       Text=""
                                       FontSize="10" Foreground="{StaticResource TextMutedBrush}"
                                       TextWrapping="Wrap"/>
                        </StackPanel>
                    </StackPanel>
                    <StackPanel Grid.Row="3" Orientation="Horizontal"
                                HorizontalAlignment="Right" Margin="0,14,0,0">
                        <Button x:Name="btnSetupCancel" Content="Cancel"
                                Width="70" Height="30" Margin="0,0,6,0"
                                FontSize="11"
                                Style="{StaticResource BrowseButtonStyle}"/>
                        <Button x:Name="btnSetupBack" Content="Back"
                                Width="70" Height="30" Margin="0,0,6,0"
                                FontSize="11" Visibility="Collapsed"
                                Style="{StaticResource BrowseButtonStyle}"/>
                        <Button x:Name="btnSetupNext" Content="Next"
                                Width="100" Height="30"
                                FontSize="11" FontWeight="SemiBold"
                                Foreground="White"
                                Style="{StaticResource BrowseButtonStyle}">
                            <Button.Background>
                                <SolidColorBrush Color="{StaticResource Accent}"/>
                            </Button.Background>
                        </Button>
                    </StackPanel>
                </Grid>
            </Border>
        </Border>
    </Grid>
</Window>
"@
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$imgLogo      = $window.FindName("imgLogo")
$txtTitle     = $window.FindName("txtTitle")
$lblStatus    = $window.FindName("lblStatus")
$statusGlow   = $window.FindName("statusGlow")
$txtSteamPath = $window.FindName("txtSteamPath")
$btnBrowse    = $window.FindName("btnBrowse")
$btnToggle    = $window.FindName("btnToggle")
$progressBar  = $window.FindName("progressBar")
$rtbLog       = $window.FindName("rtbLog")
$btnSetup         = $window.FindName("btnSetup")
$setupOverlay     = $window.FindName("setupOverlay")
$setupStepLabel   = $window.FindName("setupStepLabel")
$setupTitle       = $window.FindName("setupTitle")
$setupStep1       = $window.FindName("setupStep1")
$setupStep2       = $window.FindName("setupStep2")
$setupStep2Text   = $window.FindName("setupStep2Text")
$setupStep2Detail = $window.FindName("setupStep2Detail")
$setupStep3       = $window.FindName("setupStep3")
$setupStep3Text   = $window.FindName("setupStep3Text")
$setupStep3Branch = $window.FindName("setupStep3Branch")
$setupStep4       = $window.FindName("setupStep4")
$setupStep4Text   = $window.FindName("setupStep4Text")
$setupStep4Detail = $window.FindName("setupStep4Detail")
$rbLive           = $window.FindName("rbLive")
$rbPTB            = $window.FindName("rbPTB")
$btnSetupCancel   = $window.FindName("btnSetupCancel")
$btnSetupBack     = $window.FindName("btnSetupBack")
$btnSetupNext     = $window.FindName("btnSetupNext")
$txtSteamPath.Text = $script:steamPath
$logoPath = Join-Path $PSScriptRoot "DbD-BuildSwitcher.png"
if (Test-Path $logoPath) {
    $bitmapImage = [System.Windows.Media.Imaging.BitmapImage]::new()
    $bitmapImage.BeginInit()
    $bitmapImage.UriSource = [Uri]::new($logoPath, [UriKind]::Absolute)
    $bitmapImage.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bitmapImage.EndInit()
    $imgLogo.Source = $bitmapImage
    $imgLogo.Visibility = [System.Windows.Visibility]::Visible
    $txtTitle.Visibility = [System.Windows.Visibility]::Collapsed
}
$iconPath = Join-Path $PSScriptRoot "DbD-BuildSwitcher.ico"
if (Test-Path $iconPath) {
    $window.Icon = [System.Windows.Media.Imaging.BitmapImage]::new([Uri]::new($iconPath, [UriKind]::Absolute))
}
$script:progressStoryboard = $null
function Start-ProgressAnimation {
    $progressBar.Visibility = [System.Windows.Visibility]::Visible
    $progressBar.IsIndeterminate = $true
    $canvas = $progressBar.Template.FindName("indeterminateCanvas", $progressBar)
    $mark   = $progressBar.Template.FindName("indeterminateMark", $progressBar)
    if ($canvas -and $mark) {
        $script:progressTimer = [System.Windows.Threading.DispatcherTimer]::new()
        $script:progressTimer.Interval = [TimeSpan]::FromMilliseconds(16)
        $script:progressPos = -140.0
        $script:progressTimer.Add_Tick({
            $totalWidth = $progressBar.ActualWidth
            if ($totalWidth -le 0) { return }
            $script:progressPos += 3.0
            if ($script:progressPos -gt $totalWidth) {
                $script:progressPos = -140.0
            }
            [System.Windows.Controls.Canvas]::SetLeft($mark, $script:progressPos)
        }.GetNewClosure())
        $script:progressTimer.Start()
    }
}
function Stop-ProgressAnimation {
    if ($script:progressTimer) {
        $script:progressTimer.Stop()
        $script:progressTimer = $null
    }
    $progressBar.IsIndeterminate = $false
    $progressBar.Visibility = [System.Windows.Visibility]::Collapsed
}
function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    $colorHex = switch ($Level) {
        "Success" { "#FF00D26A" }
        "Error"   { "#FFFF3246" }
        "Warn"    { "#FFFFC107" }
        default   { "#FFD7D7E6" }
    }
    $timestamp = Get-Date -Format "HH:mm:ss"
    $doc = $rtbLog.Document
    $para = [System.Windows.Documents.Paragraph]::new()
    $para.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
    $para.LineHeight = 1
    $tsRun = [System.Windows.Documents.Run]::new("[$timestamp]  ")
    $tsRun.Foreground = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString("#FF787896")
    )
    $para.Inlines.Add($tsRun)
    $msgRun = [System.Windows.Documents.Run]::new($Message)
    $msgRun.Foreground = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString($colorHex)
    )
    $para.Inlines.Add($msgRun)
    $doc.Blocks.Add($para)
    $rtbLog.ScrollToEnd()
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
        [System.Windows.Threading.DispatcherPriority]::Background,
        [Action]{ }
    )
}
function Update-StatusLabel {
    $script:steamPath = $txtSteamPath.Text
    $p = Get-Paths
    $dot = [char]0x25CF
    if (-not (Test-Path $p.ManifestActive)) {
        $lblStatus.Text      = "$dot  UNKNOWN"
        $lblStatus.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FFFFC107")
        )
        $statusGlow.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FFFFC107")
        )
        $btnToggle.Content   = "Switch Build"
        $btnToggle.IsEnabled = $false
        Write-Log "Could not find appmanifest_381210.acf under this Steam path." "Warn"
        return
    }
    $btnToggle.IsEnabled = $true
    if (Test-Path $p.ManifestLive) {
        $lblStatus.Text      = "$dot  PTB"
        $lblStatus.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FFFF9100")
        )
        $statusGlow.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FFFF9100")
        )
        $btnToggle.Content = "Switch to LIVE"
    } else {
        $lblStatus.Text      = "$dot  LIVE"
        $lblStatus.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FF00D26A")
        )
        $statusGlow.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString("#FF00D26A")
        )
        $btnToggle.Content = "Switch to PTB"
    }
}
function Close-Steam {
    $proc = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Log "Closing Steam..." "Info"
        Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "steamwebhelper" -Force -ErrorAction SilentlyContinue
        $timeout = 0
        while ((Get-Process -Name "steam" -ErrorAction SilentlyContinue) -and $timeout -lt 20) {
            Wait-Ms 500
            $timeout++
        }
        Write-Log "Steam closed." "Success"
    } else {
        Write-Log "Steam was not running." "Info"
    }
}
function Start-Steam {
    $p = Get-Paths
    if (Test-Path $p.SteamExe) {
        Write-Log "Restarting Steam..." "Info"
        Start-Process -FilePath $p.SteamExe
        Write-Log "Steam restarted." "Success"
    } else {
        Write-Log "steam.exe not found at '$($p.SteamExe)'. Start Steam manually." "Error"
    }
}
function Switch-Build {
    $btnToggle.IsEnabled = $false
    $btnBrowse.IsEnabled = $false
    $txtSteamPath.IsEnabled = $false
    Start-ProgressAnimation
    $done = New-Object System.Collections.Generic.List[string]
    try {
        $p = Get-Paths
        if (-not (Test-Path $p.ManifestActive)) {
            Write-Log "Active manifest not found. Is Dead by Daylight installed here?" "Error"
            return
        }
        $toLive = Test-Path $p.ManifestLive
        if (-not $toLive) {
            if (-not (Test-Path $p.ManifestPTB) -or -not (Test-Path $p.FolderPTB)) {
                Write-Log "No PTB backup found. Set up the PTB copy manually once first." "Error"
                return
            }
        }
        Close-Steam
        Write-Log "Swapping build files..." "Info"
        if ($toLive) {
            Rename-Item -Path $p.ManifestActive -NewName "appmanifest_381210 - PTB.acf" -ErrorAction Stop
            $done.Add("manifest_active_to_ptb")
            Rename-Item -Path $p.ManifestLive -NewName "appmanifest_381210.acf" -ErrorAction Stop
            $done.Add("manifest_live_to_active")
            Rename-Item -Path $p.FolderActive -NewName "Dead by Daylight - PTB" -ErrorAction Stop
            $done.Add("folder_active_to_ptb")
            Rename-Item -Path $p.FolderLive -NewName "Dead by Daylight" -ErrorAction Stop
            $done.Add("folder_live_to_active")
            $newBuild = "LIVE"
        } else {
            Rename-Item -Path $p.ManifestActive -NewName "appmanifest_381210 - Live.acf" -ErrorAction Stop
            $done.Add("manifest_active_to_live")
            Rename-Item -Path $p.ManifestPTB -NewName "appmanifest_381210.acf" -ErrorAction Stop
            $done.Add("manifest_ptb_to_active")
            Rename-Item -Path $p.FolderActive -NewName "Dead by Daylight - Live" -ErrorAction Stop
            $done.Add("folder_active_to_live")
            Rename-Item -Path $p.FolderPTB -NewName "Dead by Daylight" -ErrorAction Stop
            $done.Add("folder_ptb_to_active")
            $newBuild = "PTB"
        }
        Write-Log "Switched to $newBuild build." "Success"
    } catch {
        Write-Log "Error during swap: $($_.Exception.Message)" "Error"
        Write-Log "Completed steps before failure: $($done -join ', ')" "Warn"
        Write-Log "Check the steamapps folder manually before relaunching Steam." "Warn"
    } finally {
        Start-Steam
        Update-StatusLabel
        Stop-ProgressAnimation
        $btnToggle.IsEnabled = $true
        $btnBrowse.IsEnabled = $true
        $txtSteamPath.IsEnabled = $true
    }
}
$script:setupCurrentStep = 1
$script:setupChosenBuild = "Live"
function Show-SetupOverlay {
    $script:setupCurrentStep = 1
    Update-SetupStepUI
    $setupOverlay.Visibility = [System.Windows.Visibility]::Visible
}
function Hide-SetupOverlay {
    $setupOverlay.Visibility = [System.Windows.Visibility]::Collapsed
}
function Update-SetupStepUI {
    $step = $script:setupCurrentStep
    $setupStepLabel.Text = "STEP $step OF 4"
    $setupStep1.Visibility = [System.Windows.Visibility]::Collapsed
    $setupStep2.Visibility = [System.Windows.Visibility]::Collapsed
    $setupStep3.Visibility = [System.Windows.Visibility]::Collapsed
    $setupStep4.Visibility = [System.Windows.Visibility]::Collapsed
    $setupBack = if ($step -gt 1) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $btnSetupBack.Visibility = $setupBack
    switch ($step) {
        1 {
            $setupTitle.Text = "Which build is installed?"
            $setupStep1.Visibility = [System.Windows.Visibility]::Visible
            $btnSetupNext.Content = "Next"
            $btnSetupNext.IsEnabled = $true
        }
        2 {
            $script:setupChosenBuild = if ($rbLive.IsChecked) { "Live" } else { "PTB" }
            $setupTitle.Text = "Copying your $($script:setupChosenBuild) build"
            $setupStep2Text.Text = "Closing Steam and copying your current files..."
            $setupStep2Detail.Text = "This may take several minutes for large installs. Check the activity log for progress."
            $setupStep2.Visibility = [System.Windows.Visibility]::Visible
            $btnSetupNext.Content = "Copy Now"
            $btnSetupNext.IsEnabled = $true
            $btnSetupBack.Visibility = [System.Windows.Visibility]::Visible
        }
        3 {
            $otherBuild = if ($script:setupChosenBuild -eq "Live") { "PTB" } else { "Live" }
            $setupTitle.Text = "Install the $otherBuild build"
            $setupStep3Text.Text = "Now install the $otherBuild build via Steam:"
            if ($otherBuild -eq "PTB") {
                $setupStep3Branch.Text = "4. Select the 'public-test' branch."
            } else {
                $setupStep3Branch.Text = "4. Select 'None' to go back to the Live branch."
            }
            $setupStep3.Visibility = [System.Windows.Visibility]::Visible
            $btnSetupNext.Content = "Verify Setup"
            $btnSetupNext.IsEnabled = $true
            $btnSetupBack.Visibility = [System.Windows.Visibility]::Collapsed
        }
        4 {
            $setupTitle.Text = "Verifying setup..."
            $setupStep4Text.Text = "Checking that both builds are in place..."
            $setupStep4Detail.Text = ""
            $setupStep4.Visibility = [System.Windows.Visibility]::Visible
            $btnSetupNext.Content = "Done"
            $btnSetupNext.IsEnabled = $false
            $btnSetupBack.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
}
function Invoke-SetupCopy {
    $btnSetupNext.IsEnabled = $false
    $btnSetupBack.Visibility = [System.Windows.Visibility]::Collapsed
    $btnSetupCancel.IsEnabled = $false
    Start-ProgressAnimation
    try {
        $p = Get-Paths
        if (-not (Test-Path $p.FolderActive)) {
            Write-Log "Dead by Daylight folder not found. Is the game installed?" "Error"
            $setupStep2Text.Text = "Error: game folder not found!"
            $btnSetupCancel.IsEnabled = $true
            Stop-ProgressAnimation
            return
        }
        if (-not (Test-Path $p.ManifestActive)) {
            Write-Log "Active manifest (appmanifest_381210.acf) not found." "Error"
            $setupStep2Text.Text = "Error: manifest file not found!"
            $btnSetupCancel.IsEnabled = $true
            Stop-ProgressAnimation
            return
        }
        Close-Steam
        $buildName = $script:setupChosenBuild
        if ($buildName -eq "Live") {
            $destFolder   = $p.FolderLive
            $destManifest = $p.ManifestLive
        } else {
            $destFolder   = $p.FolderPTB
            $destManifest = $p.ManifestPTB
        }
        Write-Log "Copying manifest to backup ($buildName)..." "Info"
        $setupStep2Text.Text = "Copying manifest file..."
        Copy-Item -Path $p.ManifestActive -Destination $destManifest -Force -ErrorAction Stop
        Write-Log "Manifest copied." "Success"
        Write-Log "Copying game folder... this may take several minutes." "Info"
        $setupStep2Text.Text = "Copying game folder... please wait."
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
            [System.Windows.Threading.DispatcherPriority]::Background, [Action]{ }
        )
        Copy-Item -Path $p.FolderActive -Destination $destFolder -Recurse -Force -ErrorAction Stop
        Write-Log "Game folder copied to '$destFolder'." "Success"
        $setupStep2Text.Text = "Copy complete!"
        $setupStep2Detail.Text = "Your $buildName build has been backed up. Proceed to the next step."
        Write-Log "Setup step 2 complete - $buildName build backed up." "Success"
        $script:setupCurrentStep = 3
        Update-SetupStepUI
    } catch {
        Write-Log "Error during setup copy: $($_.Exception.Message)" "Error"
        $setupStep2Text.Text = "Error during copy!"
        $setupStep2Detail.Text = $_.Exception.Message
    } finally {
        Stop-ProgressAnimation
        $btnSetupCancel.IsEnabled = $true
    }
}
function Invoke-SetupVerify {
    $btnSetupNext.IsEnabled = $false
    $btnSetupCancel.IsEnabled = $false
    Start-ProgressAnimation
    try {
        $p = Get-Paths
        $issues = @()
        if ($script:setupChosenBuild -eq "Live") {
            if (-not (Test-Path $p.FolderLive))    { $issues += "Missing folder: Dead by Daylight - Live" }
            if (-not (Test-Path $p.ManifestLive))   { $issues += "Missing manifest: appmanifest_381210 - Live.acf" }
        } else {
            if (-not (Test-Path $p.FolderPTB))     { $issues += "Missing folder: Dead by Daylight - PTB" }
            if (-not (Test-Path $p.ManifestPTB))    { $issues += "Missing manifest: appmanifest_381210 - PTB.acf" }
        }
        if (-not (Test-Path $p.FolderActive))  { $issues += "Missing active folder: Dead by Daylight" }
        if (-not (Test-Path $p.ManifestActive)) { $issues += "Missing active manifest: appmanifest_381210.acf" }
        if ($issues.Count -gt 0) {
            $setupTitle.Text = "Setup incomplete"
            $setupStep4Text.Text = "Some files are missing:"
            $setupStep4Detail.Text = ($issues -join "`n")
            foreach ($issue in $issues) { Write-Log $issue "Warn" }
            Write-Log "Setup verification found issues. Check the items above." "Warn"
            $btnSetupNext.Content = "Close"
            $btnSetupNext.IsEnabled = $true
        } else {
            $otherBuild = if ($script:setupChosenBuild -eq "Live") { "PTB" } else { "Live" }
            if ($otherBuild -eq "Live") {
                $destFolder   = $p.FolderLive
                $destManifest = $p.ManifestLive
            } else {
                $destFolder   = $p.FolderPTB
                $destManifest = $p.ManifestPTB
            }
            if (-not (Test-Path $destFolder)) {
                Write-Log "Copying new $otherBuild build to backup..." "Info"
                $setupStep4Text.Text = "Backing up the $otherBuild build..."
                [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
                    [System.Windows.Threading.DispatcherPriority]::Background, [Action]{ }
                )
                Copy-Item -Path $p.FolderActive -Destination $destFolder -Recurse -Force -ErrorAction Stop
                Write-Log "$otherBuild folder backed up." "Success"
            }
            if (-not (Test-Path $destManifest)) {
                Copy-Item -Path $p.ManifestActive -Destination $destManifest -Force -ErrorAction Stop
                Write-Log "$otherBuild manifest backed up." "Success"
            }
            $setupTitle.Text = "Setup complete!"
            $setupStep4Text.Text = "Both builds are set up and ready to switch."
            $setupStep4Detail.Text = "You can now use the main switcher to toggle between Live and PTB builds."
            Write-Log "Setup complete - both builds configured successfully." "Success"
            $btnSetupNext.Content = "Done"
            $btnSetupNext.IsEnabled = $true
        }
    } catch {
        Write-Log "Error during verification: $($_.Exception.Message)" "Error"
        $setupStep4Text.Text = "Error during verification!"
        $setupStep4Detail.Text = $_.Exception.Message
        $btnSetupNext.Content = "Close"
        $btnSetupNext.IsEnabled = $true
    } finally {
        Stop-ProgressAnimation
        $btnSetupCancel.IsEnabled = $true
    }
}
function Test-NeedsSetup {
    $p = Get-Paths
    $hasActive   = (Test-Path $p.FolderActive) -and (Test-Path $p.ManifestActive)
    $hasLive     = (Test-Path $p.FolderLive) -and (Test-Path $p.ManifestLive)
    $hasPTB      = (Test-Path $p.FolderPTB) -and (Test-Path $p.ManifestPTB)
    return ($hasActive -and -not $hasLive -and -not $hasPTB)
}
$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select your Steam install folder"
    if (Test-Path $txtSteamPath.Text) { $dlg.SelectedPath = $txtSteamPath.Text }
    if ($dlg.ShowDialog() -eq "OK") {
        $txtSteamPath.Text = $dlg.SelectedPath
        Update-StatusLabel
    }
})
$btnToggle.Add_Click({
    Switch-Build
})
$txtSteamPath.Add_TextChanged({
    Update-StatusLabel
})
$btnSetup.Add_Click({
    Show-SetupOverlay
})
$btnSetupCancel.Add_Click({
    Hide-SetupOverlay
    Update-StatusLabel
})
$btnSetupBack.Add_Click({
    if ($script:setupCurrentStep -gt 1) {
        $script:setupCurrentStep--
        Update-SetupStepUI
    }
})
$btnSetupNext.Add_Click({
    switch ($script:setupCurrentStep) {
        1 {
            $script:setupCurrentStep = 2
            Update-SetupStepUI
        }
        2 {
            Invoke-SetupCopy
        }
        3 {
            $script:setupCurrentStep = 4
            Update-SetupStepUI
            Invoke-SetupVerify
        }
        4 {
            Hide-SetupOverlay
            Update-StatusLabel
        }
    }
})
$window.Add_ContentRendered({
    Write-Log "Ready." "Info"
    Update-StatusLabel
    if (Test-NeedsSetup) {
        Write-Log "First-time setup detected - launching Setup Guide." "Info"
        Show-SetupOverlay
    }
})
[void]$window.ShowDialog()
