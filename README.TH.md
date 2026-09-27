# DesktopLayoutManager - ไลบรารี Xojo Flex Layout

ไลบรารีจัดการเลย์เอาต์ที่ทรงพลังและยืดหยุ่นสำหรับแอปพลิเคชัน Xojo Desktop ซึ่งนำความสามารถบางส่วนของ CSS Flexbox มาใช้งาน ช่วยให้สามารถออกแบบ UI ที่ตอบสนองและปรับเปลี่ยนได้ด้วยโค้ดที่น้อยที่สุด

## ภาพรวม

`DesktopLayoutManager` เป็นคลาส Xojo แบบกำหนดเองที่นำความสามารถในการจัดวางเลย์เอาต์แบบ flexbox สมัยใหม่มาสู่แอปพลิเคชันเดสก์ท็อป โดยจัดเตรียมการจัดตำแหน่งและปรับขนาดของตัวควบคุม UI (UI controls) อัตโนมัติตามกฎเลย์เอาต์ที่กำหนดค่าได้ ช่วยขจัดความจำเป็นในการจัดตำแหน่งด้วยตนเองและตรรกะการปรับขนาดที่ซับซ้อน

## คุณสมบัติหลัก

### 🎯 ความสามารถในการจัดเลย์เอาต์หลัก
- **ทิศทาง Flex (Flex Direction)**: รองรับทั้งเลย์เอาต์แนวนอน (Row) และแนวตั้ง (Column)
- **การขยาย Flex (Flex Grow)**: การปรับขนาดตัวควบคุมแบบไดนามิกเพื่อเติมเต็มพื้นที่ว่างตามสัดส่วน
- **การจัดตำแหน่งเนื้อหา (Justify Content)**: การจัดตำแหน่งตามแนวแกนหลัก (FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, Stretch, SpaceEvenly)
- **การจัดตำแหน่งไอเท็ม (Align Items)**: การจัดตำแหน่งตามแนวแกนรอง (FlexStart, FlexEnd, Center, Stretch)
- **ระยะห่าง (Spacing)**: กำหนดค่าช่องว่าง (gaps) ระหว่างตัวควบคุมและระยะขอบด้านใน (padding) รอบคอนเทนเนอร์ได้

### 🛠️ การรวมเข้าด้วยกันที่ง่ายดาย
- **รองรับ Visual Designer**: คุณสมบัติทั้งหมดสามารถกำหนดค่าได้โดยตรงใน Xojo Inspector
- **การควบคุมขณะรันไทม์ (Runtime Control)**: สามารถเพิ่ม/ลบตัวควบคุมและอัปเดตเลย์เอาต์แบบไดนามิก
- **ปรับขนาดอัตโนมัติ (Automatic Resizing)**: เลย์เอาต์จะปรับตามการเปลี่ยนแปลงขนาดของคอนเทนเนอร์โดยอัตโนมัติ
- **การจัดการการมองเห็น (Visibility Handling)**: ตัวควบคุมที่ถูกซ่อนจะถูกตัดออกจากการคำนวณเลย์เอาต์โดยอัตโนมัติ

### ⚡ ปรับแต่งประสิทธิภาพ
- **อัลกอริทึมที่มีประสิทธิภาพ**: คำนวณเลย์เอาต์ในรอบเดียว (Single-pass) โดยใช้ทรัพยากรน้อยที่สุด
- **การอัปเดตที่ชาญฉลาด**: คำนวณใหม่เฉพาะเมื่อจำเป็นเท่านั้น
- **ประหยัดหน่วยความจำ**: ใช้ dictionary เพื่อการค้นหาค่า flex-grow factor อย่างรวดเร็ว

## แกนหลักและแกนรอง (Main axis / Cross axis)

คุณสมบัติจัดตำแหน่งทั้งสองตัว **อิงตามทิศทาง (Direction)** ไม่ได้อิงตามแกน x/y ของหน้าจอ:

- **`MainAxisAlignment`** — จัด *ตามทิศ* คือแนวที่ไอเท็มเรียงต่อกัน (CSS `justify-content`, Flutter `mainAxisAlignment`)
- **`CrossAxisAlignment`** — จัด *ขวางทิศ* คือแนวตั้งฉากกับทิศที่เรียง (CSS `align-items`, Flutter `crossAxisAlignment`)

ดังนั้นเมื่อเปลี่ยน `Direction` จาก Row เป็น Column แกนบนหน้าจอที่แต่ละคุณสมบัติควบคุมจะสลับกัน ซึ่งเป็นพฤติกรรมที่ตั้งใจ

```
Direction = Row  (items go left -> right)

  MainAxisAlignment:  along the row   --->  left / centre / right, spacing
  CrossAxisAlignment: across the row   |    top / middle / bottom, stretch height
                                       v
  +---------------------------------------+
  | [A] [B] [C]                           |
  +---------------------------------------+

Direction = Column  (items go top -> bottom)

  MainAxisAlignment:  along the column   |   top / middle / bottom, spacing
                                         v
  CrossAxisAlignment: across the column --->  left / centre / right, stretch width
  +-----------+
  | [A]       |
  | [B]       |
  | [C]       |
  +-----------+
```

(แผนภาพใช้ป้ายภาษาอังกฤษเพื่อให้คอลัมน์ตรงกัน: along = ตามทิศ, across = ขวางทิศ)

| คุณสมบัติ | ค่าที่เลือกได้ | แกน | เมื่อเป็น Row | เมื่อเป็น Column |
|---|---|---|---|---|
| `Direction` | `FlexDirection`: Row, Column | กำหนดแกนหลัก | เรียงซ้าย → ขวา | เรียงบน → ล่าง |
| `MainAxisAlignment` | `JustifyContent`: FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, Stretch, SpaceEvenly | แกนหลัก (ตามทิศ) | แนวนอน | แนวตั้ง |
| `CrossAxisAlignment` | `AlignItems`: FlexStart, FlexEnd, Center, Stretch | แกนรอง (ขวางทิศ) | แนวตั้ง | แนวนอน |
| grow factor (`AddControl(c, grow)`, `SetFlexGrow`) | Double, 0 = ไม่ขยาย | แกนหลัก | ส่วนแบ่งความกว้างที่เหลือ | ส่วนแบ่งความสูงที่เหลือ |

| ค่า | `MainAxisAlignment` ใน Row / Column | `CrossAxisAlignment` ใน Row / Column |
|---|---|---|
| FlexStart | ชิดซ้าย / ชิดบน | ชิดบน / ชิดซ้าย |
| FlexEnd | ชิดขวา / ชิดล่าง | ชิดล่าง / ชิดขวา |
| Center | กึ่งกลางแนวนอน / แนวตั้ง | กึ่งกลางแนวตั้ง / แนวนอน |
| SpaceBetween | ตัวแรกและตัวสุดท้ายชิดขอบ ระยะห่างระหว่างกันเท่ากัน | — |
| SpaceAround | ระยะรอบแต่ละตัวเท่ากัน (ที่ขอบได้ครึ่งหนึ่ง) | — |
| SpaceEvenly | ระยะก่อน ระหว่าง และหลังเท่ากันทั้งหมด | — |
| Stretch | ทุกตัวขนาดเท่ากัน (เฉพาะเมื่อไม่มีตัวใด grow) | เต็มความสูง / เต็มความกว้าง |

### Grow factor: "ขอส่วนแบ่งพื้นที่ที่เหลือ"

- **Grow = 0** (ค่าเริ่มต้น): ตัวควบคุมคงขนาดของตัวเองบนแกนหลัก และ `MainAxisAlignment` เป็นตัวเลื่อนตำแหน่ง
- **Grow > 0**: ตัวควบคุมได้ส่วนแบ่งของพื้นที่ที่เหลือหลังหักตัวควบคุมขนาดคงที่และ gap ความกว้าง (Row) หรือความสูง (Column) เดิมของมันจะไม่ถูกใช้ ส่วนแบ่งเป็นสัดส่วน เช่น 1 : 2 : 3 ได้ 1/6, 2/6 และ 3/6
- ถ้า **ทุกตัว** grow จะไม่มีพื้นที่ว่างเหลือ `MainAxisAlignment` จึงไม่มีผลให้เห็น ซึ่งเป็นพฤติกรรมปกติของ flexbox (CSS `flex-grow`, Flutter `Expanded`)
- ถ้าต้องการให้คงขนาดเดิม ให้เพิ่มโดยไม่ระบุ factor: `AddControl(Button1)` หรือ `SetFlexGrow(Button1, 0)`

## การอัปเกรดจาก 1.x เป็น 2.0

| 1.x | 2.0 | ชนิด (ไม่เปลี่ยน) |
|---|---|---|
| `Justify` | `MainAxisAlignment` | `JustifyContent` |
| `Align` | `CrossAxisAlignment` | `AlignItems` |

แก้ `.Justify` และ `.Align` ในโค้ด เลย์เอาต์ที่บันทึกด้วย 1.x เก็บค่าเป็น `Justify = n` / `Align = n` ให้ตั้งค่าทั้งสองใหม่ใน Inspector หลังอัปเกรด (หรือแก้ในไฟล์โปรเจกต์แบบข้อความ เปลี่ยนสองบรรทัดนั้นเป็น `MainAxisAlignment = n` / `CrossAxisAlignment = n`)

## เริ่มต้นใช้งานด่วน

```xojo
// สร้าง layout manager
Var layoutManager As New DesktopFlexLayoutManager()
layoutManager.Left = 0
layoutManager.Top = 0
layoutManager.Width = Self.Width
layoutManager.Height = 100

// กำหนดค่าคุณสมบัติของเลย์เอาต์
layoutManager.Direction = FlexDirection.Row
layoutManager.MainAxisAlignment = JustifyContent.SpaceBetween
layoutManager.CrossAxisAlignment = AlignItems.Center
layoutManager.Gap = 10
layoutManager.PaddingLeft = 20
layoutManager.PaddingRight = 20

// เพิ่มตัวควบคุมพร้อมกำหนดค่า flex-grow
layoutManager.AddControl(button1, 0)  // ขนาดคงที่
layoutManager.AddControl(button2, 1)  // ขยายเพื่อเติมเต็มพื้นที่ว่าง
layoutManager.AddControl(button3, 2)  // ขยายเป็นสองเท่าของ button2

// นำเลย์เอาต์ไปใช้งาน
layoutManager.ApplyLayout()

// อัปเดตเมื่อมีการปรับขนาด
AddHandler Self.Resized, Sub() layoutManager.ApplyLayout()
```

## สถาปัตยกรรม

### โครงสร้างคลาส
```
DesktopFlexLayoutManager
├── Properties (คุณสมบัติ)
│   ├── Direction (FlexDirection)
│   ├── MainAxisAlignment (JustifyContent)
│   ├── CrossAxisAlignment (AlignItems)
│   ├── Gap (Integer)
│   └── Padding* (Integer)
├── Methods (เมธอด)
│   ├── AddControl(control, growFactor)
│   ├── SetFlexGrow(control, growFactor)
│   └── ApplyLayout()
└── Internal (ภายใน)
    ├── ManagedControls() Array
    ├── FlexGrowMap Dictionary
    ├── BasisWidthMap Dictionary
    └── BasisHeightMap Dictionary
```

### อัลกอริทึมของเลย์เอาต์
ตั้งแต่เวอร์ชัน 1.2.0 การคำนวณทั้งหมดอยู่ใน **`DSFlexEngine`** (โฟลเดอร์ `DSCore/`) ซึ่งใช้ร่วมกับเวอร์ชัน Desktop เมธอด `ApplyLayout()` ทำงาน 4 ขั้นตอน:

1. **รวบรวม (Collect)**: รวบรวมตัวควบคุมที่มองเห็นได้และขนาด basis ที่เก็บไว้ตอน `AddControl()`
2. **แปลงค่า (Map)**: แปลง Direction / MainAxisAlignment / CrossAxisAlignment / Gap / Padding / grow factor เป็น `DSFlexConfig` และรายการ `DSFlexItem`
3. **คำนวณ (Arrange)**: เรียก `DSFlexEngine.Arrange` (กระจาย flex, จัดแนว, ปัดขอบด้วย `Floor(x + 0.5)`, ตรวจจับ overflow)
4. **นำไปใช้ (Apply)**: กำหนดตำแหน่งภายใน WebRectangle เฉพาะค่าที่เปลี่ยน

## ตัวอย่างการใช้งาน

### แถบนำทางแนวนอน
```xojo
navLayout.Direction = FlexDirection.Row
navLayout.MainAxisAlignment = JustifyContent.SpaceBetween
navLayout.CrossAxisAlignment = AlignItems.Center
navLayout.AddControl(homeButton, 0)
navLayout.AddControl(searchField, 1)  // ขยายเพื่อเติมเต็มพื้นที่ว่าง
navLayout.AddControl(userMenu, 0)
```

### แผงการตั้งค่าแนวตั้ง
```xojo
settingsLayout.Direction = FlexDirection.Column
settingsLayout.MainAxisAlignment = JustifyContent.FlexStart
settingsLayout.CrossAxisAlignment = AlignItems.Stretch
settingsLayout.AddControl(titleSection, 0)
settingsLayout.AddControl(optionsGroup, 1)  // ขยายในแนวตั้ง
settingsLayout.AddControl(buttonBar, 0)
```

### กริดที่ตอบสนอง
```xojo
// สร้าง layout manager หลายตัวสำหรับหน้าจอขนาดต่างๆ
If Self.Width > 800 Then
    mainLayout.Direction = FlexDirection.Row
Else
    mainLayout.Direction = FlexDirection.Column
End If
```

## คุณสมบัติใหม่ที่แนะนำ

### 🚀 ความสำคัญระดับสูง
- **รองรับการตัดขึ้นบรรทัดใหม่ (Wrap Support)**: เลย์เอาต์หลายบรรทัด/หลายคอลัมน์เมื่อไอเท็มล้นขอบเขต
- **การหดตัว Flex (Flex Shrink)**: ควบคุมวิธีที่ไอเท็มหดตัวเมื่อพื้นที่มีจำกัด
- **ขนาดต่ำสุด/สูงสุด (Minimum/Maximum Sizes)**: ข้อจำกัดขนาดของแต่ละตัวควบคุม
- **การจัดตำแหน่งตนเอง (Align Self)**: การแทนที่การจัดตำแหน่งสำหรับตัวควบคุมแต่ละตัว

### 🔧 ความสำคัญระดับกลาง
- **เลย์เอาต์ซ้อนกัน (Nested Layouts)**: รองรับการใช้ layout manager ภายใน layout manager อื่น
- **รองรับแอนิเมชัน (Animation Support)**: การเปลี่ยนภาพที่ราบรื่นระหว่างการเปลี่ยนแปลงเลย์เอาต์
- **เหตุการณ์เลย์เอาต์ (Layout Events)**: คอลแบ็ก (Callbacks) สำหรับการเริ่มต้น/เสร็จสิ้นการจัดเลย์เอาต์
- **โหมดดีบัก (Debug Mode)**: แสดงภาพซ้อนทับเพื่อดูขอบเขตของเลย์เอาต์และการคำนวณ

### 🎨 ความสำคัญระดับต่ำ
- **รองรับ RTL (RTL Support)**: ทิศทางเลย์เอาต์จากขวาไปซ้าย
- **การจัดตำแหน่งตามเส้นฐาน (Baseline Alignment)**: จัดตำแหน่งไอเท็มตามเส้นฐานของข้อความ
- **แยกช่องว่าง (Gap Separation)**: กำหนดช่องว่างแนวนอนและแนวตั้งที่แตกต่างกัน
- **ปรับขนาดด้วยเปอร์เซ็นต์ (Percentage Sizing)**: รองรับการกำหนดมิติด้วยเปอร์เซ็นต์

## บันทึกการเปลี่ยนแปลง

### เวอร์ชัน 1.0.0 - เปิดตัวครั้งแรก
**✅ คุณสมบัติที่ใช้งานได้แล้ว:**
- เอนจินเลย์เอาต์ flex พื้นฐานพร้อมทิศทางแนวนอน (Row) / แนวตั้ง (Column)
- รองรับ Flex Grow สำหรับการปรับขนาดแบบไดนามิก
- โหมดการจัดตำแหน่ง Justify Content ทั้งหมด
- โหมดการจัดตำแหน่ง Align Items ทั้งหมด
- สามารถกำหนดช่องว่าง (gaps) และระยะขอบด้านใน (padding)
- รวมเข้ากับ Visual Designer
- อัปเดตเลย์เอาต์ขณะรันไทม์

**🐛 ปัญหาที่ได้รับการแก้ไข:**
- **นรกของการจัดตำแหน่งด้วยตนเอง (Manual Positioning Hell)**: ขจัดความจำเป็นในการใช้โค้ดปรับขนาดที่ซับซ้อน
- **ระยะห่างไม่สม่ำเสมอ (Inconsistent Spacing)**: ตรรกะการจัดระยะห่างแบบรวมศูนย์ช่วยป้องกันปัญหาช่องว่างหรือการทับซ้อน
- **การออกแบบที่ตอบสนอง (Responsive Design)**: ปรับตามการเปลี่ยนแปลงขนาดคอนเทนเนอร์อัตโนมัติ
- **ภาระการบำรุงรักษา (Maintenance Burden)**: เลย์เอาต์แบบประกาศ (Declarative) ช่วยลดความซับซ้อนของโค้ด

**⚡ การปรับแต่งประสิทธิภาพ:**
- คำนวณเลย์เอาต์แบบรอบเดียว (Single-pass layout calculation)
- การค้นหาค่า flex-grow ด้วย dictionary ที่มีประสิทธิภาพ
- ลดการคำนวณซ้ำระหว่างการทำงานปรับขนาดให้เหลือน้อยที่สุด

### เวอร์ชัน 1.1.0 - แก้ไข Flex Basis
**🐛 ปัญหาที่ได้รับการแก้ไข:**
- **ขนาดผิดพลาดเมื่อ Grow Factor = 0 อยู่ก่อน**: เมื่อตัวควบคุมแรกมี `growFactor = 0` และตัวควบคุมถัดมามี `growFactor > 0` ขนาดจะแสดงผลไม่ถูกต้อง สาเหตุคือ `AddControl()` เรียก `ApplyLayout()` ทุกครั้งที่เพิ่มตัวควบคุม เมื่อมีเฉพาะตัวควบคุม grow=0 โหมด Stretch จะขยายขนาดจนเต็มคอนเทนเนอร์ เมื่อเพิ่มตัวควบคุม grow>0 ในภายหลัง ขนาดที่ถูกขยายจะถูกอ่านกลับเป็น "พื้นที่คงที่" ทำให้ตัวควบคุม grow>0 ได้ขนาดเป็นศูนย์

**✅ วิธีแก้ไข:**
- เพิ่มกลไก flex-basis (`BasisWidthMap` และ `BasisHeightMap`) ที่เก็บขนาด Width และ Height ดั้งเดิมของตัวควบคุมเมื่อถูกเพิ่มผ่าน `AddControl()` อัลกอริทึมเลย์เอาต์จะใช้ค่า basis ที่เก็บไว้แทนค่า `c.Width`/`c.Height` ปัจจุบันเมื่อคำนวณพื้นที่คงที่สำหรับตัวควบคุม grow=0

### เวอร์ชัน 2.0.0 - ชื่อแกนหลัก / แกนรอง
- **เปลี่ยนแบบไม่เข้ากันกับของเดิม (Breaking)**: `Justify` เปลี่ยนชื่อเป็น `MainAxisAlignment` และ `Align` เปลี่ยนชื่อเป็น `CrossAxisAlignment` (Inspector แสดง "Main Axis Alignment" / "Cross Axis Alignment") ชนิด enum ไม่เปลี่ยน (`JustifyContent`, `AlignItems`) ดูหัวข้อ "การอัปเกรดจาก 1.x เป็น 2.0"
- **เพิ่ม**: คำอธิบายคุณสมบัติ (แสดงเป็นคำแนะนำในตัวแก้ไขโค้ด) และคำใบ้ทิศทางในรายการเลือกของ Inspector เช่น `0 - FlexStart (Row: left / Column: top)`
- **เอกสาร**: หัวข้อ "แกนหลักและแกนรอง" พร้อมแผนภาพ ตาราง และหลักการของ grow factor

### เวอร์ชัน 1.2.0 - DSFlexEngine
**✅ การเปลี่ยนแปลง:**
- `ApplyLayout()` ส่งการคำนวณทั้งหมดให้ `DSFlexEngine` (`DSCore/`) ซึ่งเป็นเอนจินเลย์เอาต์ตามสเปก Clinic DS §8.5 และใช้ร่วมกับ `DesktopFlexLayoutManager` API สาธารณะและกลไก flex-basis ไม่เปลี่ยน
- เพิ่ม `JustifyContent.SpaceEvenly` (ค่า 6 ค่าเดิมทั้งหมดความหมายคงเดิม)
- ปัดขอบทุกด้านด้วย `Floor(x + 0.5)` แทน `Round` (ซึ่งผลลัพธ์กรณี .5 ขึ้นกับระบบปฏิบัติการของเซิร์ฟเวอร์)
- เมื่อเนื้อหาใหญ่กว่าคอนเทนเนอร์ ตัวควบคุมเริ่มที่ padding แทนพิกัดติดลบ และ SpaceBetween / SpaceAround ยังคงเว้น Gap
- แกนรองใช้ขนาด basis ด้วย เมื่อเลิกใช้ CrossAxisAlignment Stretch ตัวควบคุมจะกลับเป็นขนาดเดิม

### ปัญหาที่ทราบและสิ่งที่พิจารณาในอนาคต
- **ความแม่นยำของจุดทศนิยม (Floating Point Precision)**: แก้ไขแล้วในเวอร์ชัน 1.2.0 (ปัดขอบด้วย `Floor(x + 0.5)`)
- **เลย์เอาต์ซ้อนกัน (Nested Layouts)**: ปัจจุบันยังไม่รองรับ (วางแผนไว้ในเวอร์ชัน 2.0)
- **แอนิเมชัน (Animation)**: ยังไม่มีการรองรับการเปลี่ยนภาพในตัว (วางแผนไว้ในเวอร์ชัน 2.0)

## การทดสอบ

โปรเจ็กต์นี้ครอบคลุมการทดสอบอย่างครบถ้วน:
- **Unit Tests**: อัลกอริทึมของเลย์เอาต์ทั้งหมดและกรณีขอบ (edge cases)
- **Visual Tests**: หน้าต่างตัวอย่างแสดงการกำหนดค่าเลย์เอาต์แบบต่างๆ
- **Performance Tests**: การทดสอบความเครียดด้วยตัวควบคุมจำนวนมาก
- **Edge Case Tests**: เลย์เอาต์ว่างเปล่า, คอนเทนเนอร์ขนาดศูนย์, ค่าที่รุนแรง

## ข้อกำหนด

- **เวอร์ชัน Xojo**: 2023r4 หรือใหม่กว่า
- **แพลตฟอร์มเป้าหมาย**: Desktop (Windows, macOS, Linux)
- **Dependencies**: ไม่มี (เป็นการใช้งานด้วย Xojo ล้วน)

## การร่วมให้ข้อมูล

ไลบรารีนี้ได้รับการออกแบบมาให้ขยายได้ ส่วนสำคัญสำหรับการร่วมให้ข้อมูล:
- เพิ่มโหมดการจัดตำแหน่ง
- การปรับแต่งประสิทธิภาพ
- การปรับปรุงเฉพาะแพลตฟอร์ม
- การปรับปรุงเอกสาร

## ลิขสิทธิ์

โปรเจ็กต์นี้เป็นโอเพ่นซอร์สและใช้งานได้ภายใต้ MIT License

---

**สร้างขึ้นด้วย ❤️ สำหรับชุมชน Xojo**
*ปรับปรุงการจัดเลย์เอาต์แอปพลิเคชันเดสก์ท็อปให้ทันสมัย ด้วย flex container ทีละอัน.*
