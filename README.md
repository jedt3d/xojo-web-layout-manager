# WebFlexLayoutManager

`WebFlexLayoutManager` is a custom layout manager component for Xojo Web, designed to bring CSS Flexbox-like layout capabilities natively to Xojo Web controls. It is a direct port from a Desktop version, allowing developers to create responsive, dynamic layouts without needing to write custom CSS or JavaScript.

The main idea behind `WebFlexLayoutManager` is to allow Xojo Web UI controls to be automatically positioned and sized according to flexbox rules (Row/Column direction, alignment, justification, growing, and gap spacing), recalculating positions automatically on browser resize or control visibility changes.

## Features

- **Flexbox-like Algorithm**: Implements a subset of CSS Flexbox logic in pure Xojo code. Since 1.2.0 the arithmetic lives in `DSFlexEngine` (`DSCore/`), shared with the Desktop version.
- **Direction Support**: Arrange controls in a `Row` (horizontal) or `Column` (vertical).
- **Justify Content (Main Axis)**: Support for `FlexStart`, `FlexEnd`, `Center`, `SpaceBetween`, `SpaceAround`, `Stretch` and `SpaceEvenly`.
- **Align Items (Cross Axis)**: Support for `FlexStart`, `FlexEnd`, `Center`, and `Stretch`.
- **Flex Grow**: Controls can be assigned a grow factor (via `AddControl(control, growFactor)` or `SetFlexGrow(control, factor)`) to proportionally share remaining available space.
- **Spacing Control**: Define a specific pixel `Gap` between items.
- **Padding Boundaries**: Supports `PaddingLeft`, `PaddingRight`, `PaddingTop`, and `PaddingBottom` for the container.
- **Dynamic Updates**: Automatically recalculates layout when the browser window is resized (via `Resized` event) or when control properties are updated.
- **Visibility Handling**: Automatically ignores invisible controls (`Visible = False`) and recalculates the layout for remaining visible items.

## Main axis and cross axis

The two alignment properties follow the **direction**, not the screen:

- **`MainAxisAlignment`** — *along* the direction, the way the items flow (CSS `justify-content`, Flutter `mainAxisAlignment`).
- **`CrossAxisAlignment`** — *across* the direction (CSS `align-items`, Flutter `crossAxisAlignment`).

Switching `Direction` from Row to Column therefore swaps which screen axis each property controls. This is intended.

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

| Property | Values | Axis | In a Row | In a Column |
|---|---|---|---|---|
| `Direction` | `FlexDirection`: Row, Column | chooses the main axis | items left → right | items top → bottom |
| `MainAxisAlignment` | `JustifyContent`: FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, Stretch, SpaceEvenly | main (along) | horizontal | vertical |
| `CrossAxisAlignment` | `AlignItems`: FlexStart, FlexEnd, Center, Stretch | cross (across) | vertical | horizontal |
| grow factor (`AddControl(c, grow)`, `SetFlexGrow`) | Double, 0 = none | main | share of the leftover width | share of the leftover height |

| Value | `MainAxisAlignment` in a Row / Column | `CrossAxisAlignment` in a Row / Column |
|---|---|---|
| FlexStart | left / top | top / left |
| FlexEnd | right / bottom | bottom / right |
| Center | centred horizontally / vertically | centred vertically / horizontally |
| SpaceBetween | first and last item touch the ends, equal space between | — |
| SpaceAround | equal space around each item (half at the ends) | — |
| SpaceEvenly | equal space before, between and after | — |
| Stretch | all items get equal size (only when nothing grows) | full height / full width |

### Grow factor: "I want the leftover space"

- **Grow 0** (the default): the control keeps its own size on the main axis, and `MainAxisAlignment` moves it.
- **Grow > 0**: the control takes a share of the space left after the fixed controls and the gaps; its own width (Row) or height (Column) is ignored. Shares are proportional: factors 1 : 2 : 3 get 1/6, 2/6 and 3/6.
- If **every** control grows, no free space is left, so `MainAxisAlignment` has no visible effect. This is standard flexbox behaviour (CSS `flex-grow`, Flutter `Expanded`).
- To keep natural sizes, add controls without a factor: `AddControl(Button1)`, or `SetFlexGrow(Button1, 0)`.

## Upgrading from 1.x to 2.0

| 1.x | 2.0 | Type (unchanged) |
|---|---|---|
| `Justify` | `MainAxisAlignment` | `JustifyContent` |
| `Align` | `CrossAxisAlignment` | `AlignItems` |

Replace `.Justify` and `.Align` in code. Layouts saved with 1.x store `Justify = n` / `Align = n`; re-set the two values in the Inspector after upgrading (or, in the text project file, rename those two lines to `MainAxisAlignment = n` / `CrossAxisAlignment = n`).

## Suggested New Features

- **Flex Wrap**: Support wrapping controls to a new line/column when they exceed the available container space.
- **Align Self**: Allow individual controls to override the container's `AlignItems` property.
- **Nested Layouts Support**: Improve support and testing for placing `WebFlexLayoutManager` instances inside other `WebFlexLayoutManager` instances.
- **Max/Min Constraints**: `DSFlexEngine` already supports `MinMain` / `MaxMain` and `FlexFit.Loose` per item; the class does not expose them yet (a `SetChildParams`-style method would).

## Changelog & Implementation Notes

### Initial Port & Implementation
**Problem**: Xojo Web controls rely on absolute positioning or basic locking, making complex responsive layouts difficult without writing custom WebSDK controls or injecting raw CSS.
**Solution**: Ported the desktop FlexLayoutManager to Xojo Web by subclassing `WebRectangle`. Implemented a 5-step mathematical layout algorithm entirely in Xojo code to calculate absolute `Left`, `Top`, `Width`, and `Height` properties for child controls.

### Handling Window Resizing
**Problem**: The layout needs to update automatically when the browser window changes size.
**Solution**: Utilized the `WebRectangle.Resized` event to trigger `ApplyLayout()`.

### Initial Layout Rendering Issue
**Problem**: Sometimes the layout wouldn't apply correctly on initial page load because control dimensions weren't fully realized by the browser.
**Solution**: Added a JavaScript workaround in the `Shown` event: `Me.ExecuteJavaScript("setTimeout(function(){ window.dispatchEvent(new Event('resize')); }, 50);")` to force a resize event shortly after the control is rendered on the client side.

### Flex Grow Precision
**Problem**: Distributing fractional remaining space among multiple growing controls could leave empty gaps due to integer rounding.
**Solution**: Implemented a floating-point calculation `Round((grow / totalFlexGrow) * remainingSpace)` to minimize rounding errors during distribution.

### Main axis / cross axis names (2.0.0)
- **Breaking**: `Justify` is renamed `MainAxisAlignment` and `Align` is renamed `CrossAxisAlignment` (the Inspector shows "Main Axis Alignment" / "Cross Axis Alignment"). Enum types are unchanged (`JustifyContent`, `AlignItems`). See "Upgrading from 1.x to 2.0".
- **Added**: property descriptions (code-editor tips) and axis hints in the Inspector drop-downs, for example `0 - FlexStart (Row: left / Column: top)`.
- **Docs**: "Main axis and cross axis" section with diagram, tables and the grow-factor rule.

### DSFlexEngine (1.2.0)
**Problem**: The Desktop and Web classes each had their own copy of the layout arithmetic, and the copies had drifted (for example SpaceBetween dropped `Gap` on overflow here but not on Desktop). `Round` ties also depend on the server OS.
**Solution**: `ApplyLayout()` now maps its settings to `DSFlexConfig` / `DSFlexItem`, calls `DSFlexEngine.Arrange` (the layout engine of the Clinic DS specification §8.5, `DSCore/`) and applies the results. Edges are rounded with `Floor(x + 0.5)`; overflowing content starts at the padding instead of negative positions; `JustifyContent.SpaceEvenly` (value 6) was added. Public API and the flex-basis behaviour are unchanged. See `docs/spec.yaml` › `layout_algorithm` for the full list of behaviour changes.

### Flex Basis — Grow Factor 0 Size Corruption Fix
**Problem**: When the first control in a container had `growFactor = 0` and subsequent controls had `growFactor > 0`, the layout rendered sizes incorrectly. This occurred because `AddControl()` calls `ApplyLayout()` after each addition. When only grow=0 controls existed, the `MainAxisAlignment = Stretch` path would inflate them to fill the entire container. On subsequent `AddControl()` calls that introduced grow>0 controls, the inflated size was read back as the "fixed" space, consuming all available room and leaving grow>0 controls with zero size. This bug manifested regardless of whether the container direction was Row or Column.
**Solution**: Introduced a flex-basis mechanism (`BasisWidthMap` and `BasisHeightMap`) that stores each control's original Width and Height at the time it is added via `AddControl()`. The layout algorithm now uses these stored basis values instead of the live `c.Width`/`c.Height` when calculating fixed space for grow=0 controls. This prevents intermediate layout passes from corrupting control sizes.
