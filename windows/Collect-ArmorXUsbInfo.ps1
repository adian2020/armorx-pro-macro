[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path (Get-Location) 'armorx-usb-info.json')
)

$ErrorActionPreference = 'Stop'

# Open handles with desiredAccess=0 to read descriptors only. No WriteFile,
# HID output/feature reports, firmware commands, or registry changes are used.
if (-not ('ArmorXUsbReadOnly.Enumerator' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;

namespace ArmorXUsbReadOnly {
    public sealed class HidInfo {
        public int InterfaceIndex;
        public string VendorId;
        public string ProductId;
        public string DeviceVersion;
        public string Manufacturer;
        public string Product;
        public string UsagePage;
        public string Usage;
        public int InputReportBytes;
        public int OutputReportBytes;
        public int FeatureReportBytes;
        public string DescriptorStatus;
    }

    public static class Enumerator {
        [StructLayout(LayoutKind.Sequential)]
        struct InterfaceData {
            public int Size;
            public Guid ClassGuid;
            public int Flags;
            public IntPtr Reserved;
        }
        [StructLayout(LayoutKind.Sequential)]
        struct Attributes {
            public int Size;
            public ushort VendorId, ProductId, VersionNumber;
        }
        [StructLayout(LayoutKind.Sequential)]
        struct Caps {
            public ushort Usage, UsagePage, InputLength, OutputLength, FeatureLength;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst=17)]
            public ushort[] Reserved;
            public ushort LinkNodes, InputButtons, InputValues, InputData;
            public ushort OutputButtons, OutputValues, OutputData;
            public ushort FeatureButtons, FeatureValues, FeatureData;
        }
        [DllImport("hid.dll")]
        static extern void HidD_GetHidGuid(out Guid guid);
        [DllImport("setupapi.dll", CharSet=CharSet.Unicode, SetLastError=true)]
        static extern IntPtr SetupDiGetClassDevs(ref Guid guid, IntPtr enumerator,
                                                 IntPtr parent, uint flags);
        [DllImport("setupapi.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetupDiEnumDeviceInterfaces(IntPtr set, IntPtr device,
            ref Guid guid, uint index, ref InterfaceData data);
        [DllImport("setupapi.dll", CharSet=CharSet.Unicode, SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetupDiGetDeviceInterfaceDetail(IntPtr set,
            ref InterfaceData data, IntPtr detail, uint size, out uint required,
            IntPtr device);
        [DllImport("setupapi.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetupDiDestroyDeviceInfoList(IntPtr set);
        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
        static extern SafeFileHandle CreateFile(string path, uint access, uint share,
            IntPtr security, uint creation, uint flags, IntPtr template);
        [DllImport("hid.dll", SetLastError=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool HidD_GetAttributes(SafeFileHandle handle, ref Attributes attrs);
        [DllImport("hid.dll", CharSet=CharSet.Unicode, ExactSpelling=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool HidD_GetManufacturerString(SafeFileHandle h, StringBuilder b, int bytes);
        [DllImport("hid.dll", CharSet=CharSet.Unicode, ExactSpelling=true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool HidD_GetProductString(SafeFileHandle h, StringBuilder b, int bytes);
        [DllImport("hid.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool HidD_GetPreparsedData(SafeFileHandle h, out IntPtr data);
        [DllImport("hid.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool HidD_FreePreparsedData(IntPtr data);
        [DllImport("hid.dll")]
        static extern int HidP_GetCaps(IntPtr data, out Caps caps);

        public static HidInfo[] Read() {
            var result = new List<HidInfo>();
            Guid guid;
            HidD_GetHidGuid(out guid);
            IntPtr set = SetupDiGetClassDevs(ref guid, IntPtr.Zero, IntPtr.Zero, 0x12);
            if (set == new IntPtr(-1))
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            try {
                for (uint index = 0; ; index++) {
                    var data = new InterfaceData();
                    data.Size = Marshal.SizeOf(typeof(InterfaceData));
                    if (!SetupDiEnumDeviceInterfaces(set, IntPtr.Zero, ref guid, index, ref data)) {
                        int error = Marshal.GetLastWin32Error();
                        if (error == 259) break; // ERROR_NO_MORE_ITEMS
                        throw new System.ComponentModel.Win32Exception(error);
                    }
                    uint required;
                    SetupDiGetDeviceInterfaceDetail(set, ref data, IntPtr.Zero, 0, out required, IntPtr.Zero);
                    if (required < 6 || required > 65536)
                        throw new InvalidOperationException("Invalid device-interface detail length");
                    IntPtr detail = Marshal.AllocHGlobal((int)required);
                    try {
                        Marshal.WriteInt32(detail, IntPtr.Size == 8 ? 8 : 6);
                        if (!SetupDiGetDeviceInterfaceDetail(set, ref data, detail, required,
                                                           out required, IntPtr.Zero))
                            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
                        string path = Marshal.PtrToStringUni(IntPtr.Add(detail, 4));
                        // Device paths may contain serials. Do not export them.
                        using (SafeFileHandle handle = CreateFile(path, 0, 3, IntPtr.Zero, 3, 0, IntPtr.Zero)) {
                            var info = new HidInfo();
                            info.InterfaceIndex = (int)index;
                            if (handle.IsInvalid) {
                                info.DescriptorStatus = "Open descriptor handle failed: " + Marshal.GetLastWin32Error();
                                result.Add(info);
                                continue;
                            }
                            var attrs = new Attributes();
                            attrs.Size = Marshal.SizeOf(typeof(Attributes));
                            if (HidD_GetAttributes(handle, ref attrs)) {
                                info.VendorId = attrs.VendorId.ToString("X4");
                                info.ProductId = attrs.ProductId.ToString("X4");
                                info.DeviceVersion = attrs.VersionNumber.ToString("X4");
                            }
                            var text = new StringBuilder(256);
                            if (HidD_GetManufacturerString(handle, text, 512)) info.Manufacturer = text.ToString();
                            text.Clear();
                            if (HidD_GetProductString(handle, text, 512)) info.Product = text.ToString();
                            IntPtr preparsed;
                            if (HidD_GetPreparsedData(handle, out preparsed)) {
                                try {
                                    Caps caps;
                                    int status = HidP_GetCaps(preparsed, out caps);
                                    if (status == 0x00110000) {
                                        info.UsagePage = caps.UsagePage.ToString("X4");
                                        info.Usage = caps.Usage.ToString("X4");
                                        info.InputReportBytes = caps.InputLength;
                                        info.OutputReportBytes = caps.OutputLength;
                                        info.FeatureReportBytes = caps.FeatureLength;
                                        info.DescriptorStatus = "Read descriptors only";
                                    } else info.DescriptorStatus = "HidP_GetCaps: " + status.ToString("X8");
                                } finally { HidD_FreePreparsedData(preparsed); }
                            } else info.DescriptorStatus = "Preparsed data unavailable";
                            result.Add(info);
                        }
                    } finally { Marshal.FreeHGlobal(detail); }
                }
            } finally { SetupDiDestroyDeviceInfoList(set); }
            return result.ToArray();
        }
    }
}
'@
}

$hidInterfaces = @([ArmorXUsbReadOnly.Enumerator]::Read())
$pnpStatus = 'OK'
$usbDevices = @()
try {
    $usbDevices = @(Get-CimInstance Win32_PnPEntity | Where-Object {
        $_.Present -eq $true -and $_.PNPDeviceID -match '^(USB|HID)\\VID_[0-9A-F]{4}&PID_[0-9A-F]{4}'
    } | ForEach-Object {
        $idMatch = [regex]::Match($_.PNPDeviceID, '(?i)VID_([0-9A-F]{4})&PID_([0-9A-F]{4})')
        $interfaceMatch = [regex]::Match($_.PNPDeviceID, '(?i)&MI_([0-9A-F]{2})')
        [ordered]@{
            Name = $_.Name
            VendorId = $idMatch.Groups[1].Value
            ProductId = $idMatch.Groups[2].Value
            Interface = $interfaceMatch.Groups[1].Value
            Service = $_.Service
            Status = $_.Status
        }
    })
} catch {
    # Descriptor enumeration remains useful if CIM permissions are restricted.
    $pnpStatus = 'CIM query unavailable'
}

$report = [ordered]@{
    Schema = 'armorx-usb-descriptors-v1'
    CollectedUtc = [DateTime]::UtcNow.ToString('o')
    WindowsVersion = [Environment]::OSVersion.Version.ToString()
    ProcessBits = [IntPtr]::Size * 8
    Mode = 'Descriptors only; no device commands sent'
    HeapInformation = 'Not available from standard descriptors'
    HidInterfaces = $hidInterfaces
    UsbDevices = $usbDevices
    PnpQueryStatus = $pnpStatus
}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Saved USB/HID descriptor report: $OutputPath"
Write-Host 'No firmware was written. Device serial numbers and interface paths are not included.'
