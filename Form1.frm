VERSION 5.00
Begin VB.Form Form1 
   BackColor       =   &H00DEBD92&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   1920
   ClientLeft      =   15
   ClientTop       =   15
   ClientWidth     =   3630
   ControlBox      =   0   'False
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   128
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   242
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox picHook 
      Height          =   615
      Left            =   1440
      ScaleHeight     =   555
      ScaleWidth      =   795
      TabIndex        =   0
      Top             =   960
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.Timer Timer1 
      Interval        =   1
      Left            =   1560
      Top             =   720
   End
   Begin VB.Label Y 
      Caption         =   "0"
      Height          =   615
      Left            =   2640
      TabIndex        =   2
      Top             =   840
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.Label X 
      Caption         =   "0"
      Height          =   615
      Left            =   2640
      TabIndex        =   1
      Top             =   600
      Visible         =   0   'False
      Width           =   615
   End
   Begin VB.Image Image1 
      Height          =   1440
      Left            =   840
      Stretch         =   -1  'True
      Top             =   240
      Width           =   1500
   End
   Begin VB.Menu mnuFile 
      Caption         =   ""
      Visible         =   0   'False
      Begin VB.Menu mnuHide 
         Caption         =   "Hide"
      End
      Begin VB.Menu mnuShow 
         Caption         =   "Show"
      End
      Begin VB.Menu mnuSep 
         Caption         =   "-"
      End
      Begin VB.Menu mnuExit 
         Caption         =   "Exit"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const RC_PALETTE As Long = &H100
Const SIZEPALETTE As Long = 104
Const RASTERCAPS As Long = 38
Private Type PALETTEENTRY
    peRed As Byte
    peGreen As Byte
    peBlue As Byte
    peFlags As Byte
End Type
Private Declare Function GetCursorPos Lib "User32" (lpPoint As POINTAPI) As Long
Private Type POINTAPI
    X As Long
    Y As Long
End Type
Private Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
End Type
Private Type LOGPALETTE
    palVersion As Integer
    palNumEntries As Integer
    palPalEntry(255) As PALETTEENTRY ' Enough for 256 colors
End Type
Const HWND_TOPMOST = -1
Const HWND_NOTOPMOST = -2
Const SWP_NOSIZE = &H1
Const SWP_NOMOVE = &H2
Const SWP_NOACTIVATE = &H10
Const SWP_SHOWWINDOW = &H40
Private Declare Sub SetWindowPos Lib "User32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long)
Private Type NOTIFYICONDATA
    cbSize As Long
    hwnd As Long
    uId As Long
    uFlags As Long
    ucallbackMessage As Long
    hIcon As Long
    szTip As String * 64
End Type
Private Const NIM_ADD = &H0
Private Const NIM_MODIFY = &H1
Private Const NIM_DELETE = &H2
Private Const WM_MOUSEMOVE = &H200
Private Const NIF_MESSAGE = &H1
Private Const NIF_ICON = &H2
Private Const NIF_TIP = &H4
Private Const WM_LBUTTONDBLCLK = &H203
Private Const WM_LBUTTONDOWN = &H201
Private Const WM_LBUTTONUP = &H202
Private Const WM_RBUTTONDBLCLK = &H206
Private Const WM_RBUTTONDOWN = &H204
Private Const WM_RBUTTONUP = &H205
Private Declare Function Shell_NotifyIcon Lib "shell32" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, pnid As NOTIFYICONDATA) As Boolean
Dim Systray As NOTIFYICONDATA
Private Type GUID
    Data1 As Long
    Data2 As Integer
    Data3 As Integer
    Data4(7) As Byte
End Type
Private Type PicBmp
    Size As Long
    Type As Long
    hBmp As Long
    hPal As Long
    Reserved As Long
End Type
Private Declare Function OleCreatePictureIndirect Lib "olepro32.dll" (PicDesc As PicBmp, RefIID As GUID, ByVal fPictureOwnsHandle As Long, IPic As IPicture) As Long
Private Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long
Private Declare Function CreateCompatibleBitmap Lib "gdi32" (ByVal hdc As Long, ByVal nWidth As Long, ByVal nHeight As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function GetDeviceCaps Lib "gdi32" (ByVal hdc As Long, ByVal iCapabilitiy As Long) As Long
Private Declare Function GetSystemPaletteEntries Lib "gdi32" (ByVal hdc As Long, ByVal wStartIndex As Long, ByVal wNumEntries As Long, lpPaletteEntries As PALETTEENTRY) As Long
Private Declare Function CreatePalette Lib "gdi32" (lpLogPalette As LOGPALETTE) As Long
Private Declare Function SelectPalette Lib "gdi32" (ByVal hdc As Long, ByVal hPalette As Long, ByVal bForceBackground As Long) As Long
Private Declare Function RealizePalette Lib "gdi32" (ByVal hdc As Long) As Long
Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Private Declare Function DeleteDC Lib "gdi32" (ByVal hdc As Long) As Long
Private Declare Function GetDC Lib "User32" (ByVal hwnd As Long) As Long
Function CreateBitmapPicture(ByVal hBmp As Long, ByVal hPal As Long) As Picture
    Dim R As Long, Pic As PicBmp, IPic As IPicture, IID_IDispatch As GUID

    'Fill GUID info
    With IID_IDispatch
        .Data1 = &H20400
        .Data4(0) = &HC0
        .Data4(7) = &H46
    End With

    'Fill picture info
    With Pic
        .Size = Len(Pic) ' Length of structure
        .Type = vbPicTypeBitmap ' Type of Picture (bitmap)
        .hBmp = hBmp ' Handle to bitmap
        .hPal = hPal ' Handle to palette (may be null)
    End With

    'Create the picture
    R = OleCreatePictureIndirect(Pic, IID_IDispatch, 1, IPic)

    'Return the new picture
    Set CreateBitmapPicture = IPic
End Function
Function hDCToPicture(ByVal hDCSrc As Long, ByVal LeftSrc As Long, ByVal TopSrc As Long, ByVal WidthSrc As Long, ByVal HeightSrc As Long) As Picture
    Dim hDCMemory As Long, hBmp As Long, hBmpPrev As Long, R As Long
    Dim hPal As Long, hPalPrev As Long, RasterCapsScrn As Long, HasPaletteScrn As Long
    Dim PaletteSizeScrn As Long, LogPal As LOGPALETTE

    'Create a compatible device context
    hDCMemory = CreateCompatibleDC(hDCSrc)
    'Create a compatible bitmap
    hBmp = CreateCompatibleBitmap(hDCSrc, WidthSrc, HeightSrc)
    'Select the compatible bitmap into our compatible device context
    hBmpPrev = SelectObject(hDCMemory, hBmp)

    'Raster capabilities?
    RasterCapsScrn = GetDeviceCaps(hDCSrc, RASTERCAPS) ' Raster
    'Does our picture use a palette?
    HasPaletteScrn = RasterCapsScrn And RC_PALETTE ' Palette
    'What's the size of that palette?
    PaletteSizeScrn = GetDeviceCaps(hDCSrc, SIZEPALETTE) ' Size of

    If HasPaletteScrn And (PaletteSizeScrn = 256) Then
        'Set the palette version
        LogPal.palVersion = &H300
        'Number of palette entries
        LogPal.palNumEntries = 256
        'Retrieve the system palette entries
        R = GetSystemPaletteEntries(hDCSrc, 0, 256, LogPal.palPalEntry(0))
        'Create the palette
        hPal = CreatePalette(LogPal)
        'Select the palette
        hPalPrev = SelectPalette(hDCMemory, hPal, 0)
        'Realize the palette
        R = RealizePalette(hDCMemory)
    End If

    'Copy the source image to our compatible device context
    R = BitBlt(hDCMemory, 0, 0, WidthSrc, HeightSrc, hDCSrc, LeftSrc, TopSrc, vbSrcCopy)

    'Restore the old bitmap
    hBmp = SelectObject(hDCMemory, hBmpPrev)

    If HasPaletteScrn And (PaletteSizeScrn = 256) Then
        'Select the palette
        hPal = SelectPalette(hDCMemory, hPalPrev, 0)
    End If

    'Delete our memory DC
    R = DeleteDC(hDCMemory)

    Set hDCToPicture = CreateBitmapPicture(hBmp, hPal)
End Function




Private Sub Form_Load()
If App.PrevInstance = True Then
MsgBox "ERROR: YOU CAN ONLY RUN ONE MAGNIFIER ONCE AT A TIME :)", vbCritical, "Error"
End
End If
SetWindowPos Me.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE Or SWP_SHOWWINDOW Or SWP_NOMOVE Or SWP_NOSIZE
With Systray
.cbSize = Len(Systray)
.hIcon = Me.Icon
.hwnd = picHook.hwnd
.szTip = "Magnifier :)"
.ucallbackMessage = WM_MOUSEMOVE
.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
.uId = 1&
End With
Shell_NotifyIcon NIM_ADD, Systray
End Sub

Private Sub Form_Unload(Cancel As Integer)
Systray.cbSize = Len(Systray)
Systray.hwnd = picHook.hwnd
Systray.uId = 1&
Shell_NotifyIcon NIM_DELETE, Systray
End
End Sub

Private Sub mnuExit_Click()
Unload Me
End
End Sub

Private Sub mnuHide_Click()
Me.Hide
Timer1.Enabled = False
End Sub

Private Sub mnuShow_Click()
Me.Show
Timer1.Enabled = True
End Sub

Private Sub picHook_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Static rec As Boolean, msg As Long
msg = X / Screen.TwipsPerPixelX
If rec = False Then
rec = True
Select Case msg
Case WM_RBUTTONUP:
Me.PopupMenu mnuFile
Case WM_LBUTTONDBLCLK:
Me.Show
End Select
rec = False
End If
End Sub

Private Sub Timer1_Timer()
Dim p As POINTAPI
Dim FLAGa  As Boolean, FLAGb As Boolean, FLAGc As Boolean, FLAGd As Boolean
FLAGa = False: FLAGb = False: FLAGc = False: FLAGd = False
GetCursorPos p
If p.X = X.Caption And p.Y = Y.Caption Then
Exit Sub
End If
X.Caption = p.X
Y.Caption = p.Y
If p.X >= 775 Then
FLAGa = True
End If
If p.Y >= 592.5 Then
FLAGd = True
End If
If p.Y <= 10 Then
FLAGb = True
End If
If p.X <= 13 Then
FLAGc = True
End If
Image1.Move 0, 0, 5000, 5000
If (FLAGa = True) And (FLAGb = True) Then
Exit Sub
ElseIf FLAGa = True Then
Set Image1.Picture = hDCToPicture(GetDC(0), p.X - 40, p.Y - 8, Screen.Width / Screen.TwipsPerPixelX, Screen.Height / Screen.TwipsPerPixelY)
ElseIf FLAGb = True Then
Set Image1.Picture = hDCToPicture(GetDC(0), p.X, p.Y, Screen.Width / Screen.TwipsPerPixelX, Screen.Height / Screen.TwipsPerPixelY)
ElseIf FLAGc = True Then
Set Image1.Picture = hDCToPicture(GetDC(0), p.X, p.Y - 8, Screen.Width / Screen.TwipsPerPixelX, Screen.Height / Screen.TwipsPerPixelY)
ElseIf FLAGd = True Then
Set Image1.Picture = hDCToPicture(GetDC(0), p.X, p.Y - 15, Screen.Width / Screen.TwipsPerPixelX, Screen.Height / Screen.TwipsPerPixelY)
Else
Set Image1.Picture = hDCToPicture(GetDC(0), p.X - 20, p.Y - 9, Screen.Width / Screen.TwipsPerPixelX, Screen.Height / Screen.TwipsPerPixelY)
End If
End Sub
'ONLY WORKS ON SCREENS THAT ARE 800x600 OR YOU MUST CHANGE THE CODE YOURSELF!
Private Sub X_Click()

End Sub
