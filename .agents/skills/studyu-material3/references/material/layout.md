# Material 3 · Layout

<!-- Source: m3.material.io · foundations_layout_layout-overview · updated 2026-08-18T21:59:38.343Z · CC-BY 4.0 (Google) -->

## Layout overview

> Layout is the visual and strategic arrangement of elements on a screen



<!-- section: Overview -->

-
Use layout to organize all elements in a screen, signal hierarchy, and draw attention to key actions

-
Adapt layouts to compact, medium, expanded, large, and extra-large breakpoints (previously window size classes)

-
Build from an established [canonical layout example](/m3/pages/canonical-examples)

-
Design for [bidirectionality](/m3/pages/bidirectionality-rtl) to support both left-to-right (LTR) and right-to-left (RTL) languages

-
Apply consistent arrangement, sizing, and spacing to create a functional layout structure

-
Material layout guidance is implemented on Android and applies to web

_footer: - Column  - Fold  - Margin  - Bar  - Drag handle  - Pane  - Rail_
_altText: 7 elements of layout._

## Availability & resources

**Type**
 |
**Resource**
 |
**Status**
 |

Design
 |
[M3 Design Kit](https://www.figma.com/community/file/1035203688168086460) (Figma)
 |
Available
 |

[Spacing system & tokens](/m3/pages/spacing/overview)
 |
Available
 |

Implementation
 |
[Jetpack Compose: Canonical layouts](https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts)
 |
Available
 |

[Jetpack Compose: Rulers](https://developer.android.com/reference/kotlin/androidx/compose/ui/layout/Ruler)
 |
Available
 |

[Android Views (MDC-Android): Canonical layouts](https://github.com/android/user-interface-samples/tree/main/CanonicalLayouts)
 |
Available
 |

[Jetpack Compose: Navigation3](https://developer.android.com/guide/navigation/navigation-3/migration-guide)
 |
Available
 |

## What's new

When creating new layouts, use the layout scaffold, start from a canonical layout example, and ensure layouts scale across breakpoints.

##### **May 2026**

Layout structure and design:

-
Introduced layout scaffold, to create adaptive layouts efficiently

-
New adaptive guidelines for mobile, desktop, and spatial devices

-
Updated canonical layout examples

-
[Spacing system](/m3/pages/spacing/overview)

Naming:

-
Window size classes renamed to breakpoints

-
Responsive layout renamed to [adaptive design](/m3/pages/layout-overview/adaptive-design)

_footer: The Material layout scaffold enables layouts to adapt across different screen sizes_
_altText: Compact and expanded layouts for differently sized screens._

## Layout terms

-
**Adaptive design**: Techniques that allow an interface to dynamically respond to contexts like user preferences, device type, state, and breakpoints

-
**Bars**: Can frame the page to help people navigate through a product, and typically house the app bar and bottom navigation bar

-
**Bidirectionality**: A writing system that displays text and content from right-to-left (RTL) 

-
**Breakpoints**: Opinionated window sizes where a layout changes to match available space, device conventions, and ergonomics (previously window size classes)

-
**Column**: One or more vertical blocks of content within a pane

-
**Drag handle**: The component that resizes panes

-
**Fold**: A flexible area of the screen or a hinge that separates two displays on foldable devices

-
**Gap**: The space between components or elements within a container

-
**Margin**: The space between the edge of the screen and any elements inside of it

-
**Multi-window mode**: Enables multiple apps to share the same screen simultaneously

-
**Pane**: A layout container that houses other components and elements within a single app. A pane can be fixed, flexible, floating, or semi-permanent.

-
**Rails**: The perimeter space surrounding panes that holds key elements such as navigation rails, toolbars, and pane control

-
**Right-to-left (RTL) language**: Languages written and read right-to-left, such as Arabic, Hebrew, and Farsi, used by [over 2 billion people](https://www.w3.org/International/questions/qa-scripts.en.html)

-
**Rulers**: An opinionated set of global alignment lines that help organize building blocks in a layout

-
**Safety region**: Zones reserved for system UI elements outside the application space, such as status bar or gesture bar

-
**Scaffold**: A fundamental UI design structure that provides a standard platform for assembling key screen components

-
**Spacer**: The space between two panes on a foldable device

<!-- section: Parts of layout -->

## Parts of layout

### Windows

A window frames and contains an app or product.

Many systems support multi-window views, which display multiple apps at once.

[Multi-window support guide for Android](https://developer.android.com/develop/ui/compose/layouts/adaptive/support-multi-window-mode)

_footer: Two windows can be shown at once with a taskbar underneath_
_altText: Stacked windows with a single taskbar underneath._

On desktop, windows can be resized and moved around freely. They should adapt to various screen sizes.

[More on adaptive design](/m3/pages/layout-overview/adaptive-design)

_footer: Windows can be moved around, resized, and adapt to different screen sizes_
_altText: 2 overlapping desktop windows._

### Grids

The layout grid is the foundation for every layout. It provides a structural framework for organizing components, content, and actions.

Use the grid to:

-
Group related information in columns

-
Apply spacing consistently

-
Create focal points for primary actions

-
Align building blocks like bars, rails, and panes

[More on grids](/m3/pages/grids-spacing/grids)

_footer: Column count, width, and spacing dynamically adjust to different breakpoints_
_altText: Side-by-side compact and expanded windows with different grid spacing._

## Layout scaffold

### Bars

Bars help people navigate through a product. Use bars to:

-
Frame the main content

-
Contain an app bar or navigation bar

-
Span one or multiple panes  

[More on bars](/m3/pages/scaffold/bars)

_footer: 1. App bars are placed at the top of the screen to help people navigate by providing a description of the screen and 1–2 essential actions, like search or back navigation_
_altText: A photo app with an app bar below the safety region._

### Rails

Rails are the next level in layout after bars, filling the perimeter space surrounding panes, or floating above them. They contain key elements such as navigation rails, toolbars, chat inputs, FABs, and other primary controls.

[More on rails](/m3/pages/scaffold/rails)

_footer: - On mobile, the rail region can contain a toolbar  - On desktop, the rail region can contain the navigation rail_
_altText: Mobile layout with a toolbar, and a desktop layout with a start-aligned navigation rail._

### Panes

Just like panes of glass that make up a window in the real world, panes in Material make up most of the layout in a window.

All content must be in a pane. A layout can contain 1–3 panes of various widths, which adapt dynamically to the breakpoint (formerly window size class) and the person’s language setting. For right-to-left (RTL) languages, navigation components will be on the right.

People can navigate to or between panes. Presenting multiple panes at once can make a product more efficient and easier to use.

[More on panes](/m3/pages/scaffold/panes/)

_footer: - First pane  - Second pane_
_altText: 2-pane layout on a tablet._

#### Containment

On most devices, panes can blend in with the background. This is called implicit grouping, and helps show relationships between panes.

Explicit grouping uses distinct colors or outlines to visually delineate content.

[More on spacing to group content](/m3/pages/grids-spacing/spacing#e7e6d1ac-031a-4757-afcf-b223f23654ea)

_footer: In multiple-pane layouts, use color to show emphasis and close spacing to group related content_
_altText: 2 panes in an email app, with the same color as the background._

In spatial environments, panes use a container color to separate them from the passthrough or virtual environment.

_footer: Use contrast between panes and the background to create a spatial effect in XR_
_altText: 2-pane layout in a spatialized environment, with a virtual reality background._

### Drag handles

Drag handles can be used to resize panes in a layout. They can:

-
Adjust the width of flexible panes

-
Fully collapse and expand fixed panes to quickly switch between a single and two-pane layout

_footer: Drag handles can adjust pane size in a list-detail layout_
_altText: A drag handle is used to collapse a two-pane layout into a single-pane layout._

### Rulers

Rulers are a set of global alignment lines. They help to align elements across all layers of the layout.

[How to implement rulers in Compose](https://developer.android.com/reference/kotlin/androidx/compose/ui/layout/Ruler)

_footer: Rulers ensure global alignment across a product, keeping margins and placement consistent_
_altText: A 2-pane email in box, with rulers._

<!-- section: Adaptive design -->

## What’s adaptive design?

Adaptive design is a set of techniques to change an interface to fit different contexts. While responsive design scales a single layout to fit any screen, adaptive design customizes a product to optimize the experience on each device.

Designing adaptive experiences goes beyond customizable properties like color, typography, and shape. The structure, individual components, and entire layouts can adapt based on:

-
People: Individual preferences and settings

-
Devices: Watch, phone, foldable, tablet, desktop, or XR device

-
Usage: Screens dynamically change as a person resizes windows, changes orientation, or switches device

## Designing adaptive experiences

Layouts must be versatile, designed to adapt fluidly across three primary experience types: **mobile**, **desktop**, and **spatial**. Start with mobile and make sure your product's layout and components can scale and adapt seamlessly all the way up to spatial environments.

While each experience has different primary input methods, designs should be built with all inputs in mind—touch, pointer, and physical keyboard—since users may use your product in a desktop environment regardless of their device type.

### Mobile

Mobile experiences include phones, foldables, and tablets.

On mobile, an app can be shown in several window modes:

-
Full-screen: The app takes up the entire screen, the default for mobile

-
Split-screen: Two or more apps share the screen simultaneously, common on tablets and foldables

-
Bubbles: Floating windows that let people multitask without leaving their current context

_footer: Mobile layouts default to a full-screen window_
_altText: A mobile app in full screen mode._

### Desktop

Desktop experiences use free-form windows that adapt across breakpoints.

People can use split screens, floating windows, and free-form windows for multi-tasking.

A tablet can convert to a desktop experience when a physical keyboard and mouse are connected. Similarly, Android mobile devices can transition into a desktop-like environment when connected to an external monitor.

_footer: A desktop layout can adjust from three to two columns to fit a medium breakpoint_
_altText: 2 desktop layouts adapted to large and medium breakpoints._

### Spatial

Extended reality (XR) experiences use multiple free-form windows within virtually limitless screens. Immersive modes, such as Android XR’s [full space](https://developer.android.com/design/ui/xr/guides/foundations), allow components to be positioned freely in 3D space.

[More on XR design](/m3/pages/xr-design)

_footer: In an XR full space layout, a navigation rail can become an orbiter, and float to the side of the main pane_
_altText: An XR layout inimmersive full space mode._

## Adaptive layouts

The Material 3 adaptive system uses panes and breakpoints to organize content into adaptive layouts.

Panes are the building blocks of layout; a pane is a single destination in the product. For example, in a messaging app, the list of messages is one pane, and and a specific conversation thread is another.

_footer: Panes are the primary segments of a layout, and can change based on context_
_altText: Mobile and tablet in portrait layout with 1 pane. Tablet in landscape layout with 2 panes._

As the pane or window resizes—or as someone navigates a product—panes may change size, enter and exit the screen, and reorganize themselves to make the experience more usable or easier to navigate. These patterns are called adaptive strategies. Material has three adaptive strategies that create a cohesive experience across breakpoints: [show and hide](/m3/pages/scaffold/panes#bbe68948-bc05-4f7c-b870-6254439e4fd8), [levitate](/m3/pages/scaffold/panes#96bf71b8-04b8-4fff-97c7-9bc782fbf401), and [reflow](/m3/pages/scaffold/panes#e0a573e9-8c62-4772-8d81-47955ff83196).

_footer: Co-planar: Panes are displayed side by side_
_altText: A foldable open screen with 2 co-planar panes displayed side by side._

_footer: Floating: A pane is displayed above other panes or content, like a dialog_
_altText: A  foldable open screen with a floating pane displayed above other elements._

_footer: Docked: A pane is displayed above other panes and one of its edges extends beyond one side of the screen, like a bottom sheet_
_altText: A  foldable open screen with a docked pane to the bottom of the screen displayed above other elements._

In Compose, the [Navigation 3](https://developer.android.com/guide/navigation/navigation-3) library allows multiple destinations to be shown on screen at the same time, and enables layouts to adapt seamlessly across window sizes and screens.

_footer: Navigation destinations remain consistent regardless of screen sizes with Navigation 3_
_altText: A video demonstrating how navigation destinations remain consistent across screen sizes using the Navigation 3 library._

### Adapting components

Components can adapt in appearance, placement, and behavior based on factors like:

-
Where components are placed in relation to their containers, content, and pane boundaries

-
How components use space

-
How components enable usage across different device and input types

Most Material components respond using three main strategies: resizing, showing and hiding, and presentation changes.

#### Resizing

Components should resize in response to their content and their placement in a layout.

For example, buttons may scale along with their parent container, or hug their contents and maintain a left or right alignment.

_footer: Buttons can hug their contents or span their containers based on context_
_altText: A card with a button that spans the full width, and a card with a button that’s start-aligned and hugs its contents._

#### Showing & hiding

Components should show and hide information, or collapse and expand to selectively reveal content that best suits the space.

For example, list items may reveal descriptions or other additional information as their parent container scales.

_footer: List items can reveal more text on a tablet_
_altText: A list on mobile and on tablet. List items show additional text on tablet._

#### Presentation changes

Presentation changes include the orientation of elements and changes to specific properties, like color, type, and shape.

Components can also change configurations. For example, when a window size increases, a FAB can change to an extended FAB, and navigation rails can be automatically expanded.

_footer: The extended FAB can change to a standard FAB when the window is smaller_
_altText: A large desktop window with an extended FAB. A smaller window shows a standard FAB._

## Grouping

Grouping is a method for connecting related elements that share a context, such as an image grouped with a caption. It visually relates elements and establishes boundaries to differentiate unrelated elements.

_footer: By placing a caption under an image this composition shows an explicit group_
_altText: Photo of dumplings with a caption reading “restaurants in the area”_

**Explicit grouping** uses visual boundaries such as outlines, dividers, and shadows to group related elements in an enclosed area. Explicit grouping can also indicate that an item is interactive, such as list items contained between dividers, or a card displaying an image and its caption.

_footer: The elements in this card are explicitly grouped_
_altText: Container of a contact grouped with photo and caption_

**Implicit grouping** uses close proximity and open space (rather than lines and shadows) to group related items. For example, a headline closely followed by a subhead and thumbnail image are implicitly grouped together by proximity and separated from other headline-subhead-thumbnail groups by open space.

_footer: Images in a carousel are grouped by their proximity_
_altText: Carousel of images_

## Margins

Margins are the spaces between the edge of a window area and the elements within that window area.

Margin widths are defined using fixed or scaling values for each window size class. To better adapt to the window, the margin width can change at different breakpoints. Wider margins are more appropriate for larger screens, as they create more open space around the perimeter of content.

See margin measurements for each window class: compact, medium, expanded, large, and extra-large.

_footer: A margin separates the edge of the screen from the elements on the screen_
_altText: Screen highlighting vertical blue margin on left side of screen_

## Spacers

A spacer refers to the space between two panes in a layout. Spacers measure 24dp wide.

_footer: - A spacer splits two panes from each other_
_altText: Screen highlighting vertical blue margin on left side of screen_

A spacer can contain a drag handle that adjusts the size and layout of the panes. The handle's touch target slightly overlaps the panes.

_footer: - Drag handle touch target_
_altText: Pane drag handle touch target overlapping two panes._

## Padding

Padding refers to the space between UI elements. Padding can be measured vertically and horizontally and does not need to span the entire height or width of a layout. Padding is measured in increments of 4dp.

_footer: - Padding separates a headline from a image above_
_altText: Full screen-width photo with padding below it and text below the padding_

## Overview

- Information density is the consideration of the amount of information visible on the screen
- The default target size should be at least 48x48 CSS pixels
- Users can change density as long as the density controls are accessible
- Apply density thoughtfully; not every layout needs it
- Layout and component scaling (component adaptation or component density) can allow users to scan, view, or compare more information at once

_footer: Information density_
_altText: A website design with a denser arrangement of text and graphics._

_footer: Component scaling_
_altText: Visual representation of component scaling with multiple size examples._

**Information density**

- Information density can be achieved through layout and design decisions without using component scaling
- Users may not benefit from increased density

**Component scaling**

- Components can adapt and change dimensions to allow users to scan, view, or compare different amounts of information
- Don't apply component scaling by default if it would result in a target below 48x48 CSS pixels

_footer: Information density and component scaling can be used together to provide more information and additional user control_
_altText: An email app on desktop with a menu open to change information density between cozy, comfortable, and compact._

## Information density

Information density refers to the amount of content (such as text, images, or videos) in a given screen space.

A layout’s spacing dimensions, including margins, spacers, and padding, can change to increase or decrease its information density. High density layouts can be useful when users need to scan, view, or compare a lot of information, such as in a data table. Increasing the layout density of lists, tables, and long forms makes more content available on-screen.

Consider density settings in the context of a device. Although a user may prefer a denser layout for desktop, they may not for mobile. Density shouldn’t automatically change across window-size classes or device orientation without users changing it.

_footer: Consider using higher density information design when users need to scan lots of information_
_altText: High density layout_

_footer: Consider the amount and priority of information on-screen. Higher density can be useful for data-rich sites (news, financial portals, dashboards) where users expect lots of information quickly._
_altText: News website on desktop displaying a high information density._

_footer: Lower density can be better for sites prioritizing aesthetics, a focused message, less information, or easier navigation_
_altText: News website on desktop displaying a low information density._

## Component scaling

The component density scale controls the internal spacing of individual components.

The density scale is numbered, starting at 0 for a component’s default density. The scale moves to negative numbers (-1, -2, -3) as space decreases, creating higher density.

Higher density is typically applied by decreasing the top and bottom padding or overall height by 4dp.

_footer: Buttons in 3 different densities. Apply button density based on the needs and layout of a design._
_altText: Three buttons, with densities  of +1, 0, and -1._

Center the grouped element within the component container.

Text size shouldn’t change as the container size scales.

_footer: The measurement between the label and input is 20dp_
_altText: Stacked element showing 20 dp between label and input_

_footer: The label and input are centered within their parent container_
_altText: Parent container showing label above input._

_footer: Don’t increase density in UIs that involve focused tasks, such as selecting from a menu. It reduces usability by limiting selectable space._
_altText: Dropdown menu selectable space  height of 36 dp_

_footer: Don't increase the density in components that alert the user of changes, such as snackbars or dialogs_
_altText: Single-line snackbar_

### Avoid applying component scaling by default

- Don't apply component scaling to layouts by default that lower the target size below a default size of 48x48 CSS pixels
- Allow users to opt for a higher density layout or theme, and provide a simple, accessible way to revert to default best practices

People should be able to **opt****in** to dense layouts and components.

To ensure that density settings can be easily reverted, targets in settings interactions must follow defaults (48x48 CSS pixels).

_altText: A density menu with large, medium, and small options to customize the screen layout of a table on desktop._

## Targets

Dense components can be less accessible because interactive elements are smaller, so use caution when increasing information density.

_footer: Use caution when applying component scaling where selectable targets will be reduced to less than the 48x48dp best practice and only apply density where it provides a better user experience._
_altText: Selectable target of only 40 dp_

Use caution when applying density to interaction targets. Following best practices, accessible targets should retain a minimum of 48x48dp, even if their visual element (such as an icon) is smaller.

_footer: The target should remain 48x48, even if the icon is smaller._
_altText: Settings button is 24 by 24 dp, but has interaction target of 48 x 48 dp._

_footer: The interaction target of a common button can be larger, as long as it meets the 48x48dp minimum size._
_altText: Button with height of 36 dp and interaction target of 48 dp_

## Pixel density

The number of pixels that fit into an inch is referred to as pixel density. High-density screens have more pixels per inch than low-density ones. As a result, UI elements of the same pixel dimensions appear larger on low-density screens, and smaller on high-density screens.

To calculate pixel density:

Screen density = Screen width (or height) in pixels / Screen width (or height) in inches

_footer: A high-density ui element_
_altText: Magnified UI element  showing a high number pixels in the focus area_

_footer: A low-density UI element_
_altText: Magnified UI element  showing the low number of pixels in the focus area_

### Density-independent pixels

Density-independent pixels, written as dp, are flexible units that scale to have uniform dimensions on any screen. They provide a flexible way to accommodate a design across devices. Material design system uses density-independent pixels to display elements consistently on screens with different densities.

A dp is equal to one physical pixel on a screen with a density of 160.

To calculate dp: dp = (width in pixels * 160) / screen density

_footer: Low-density screen displayed with density independence_
_altText: Screen with grid representing  low number of pixels_

_footer: High-density screen displayed with density independence_
_altText: Screen with grid representing  high number of pixels_

Screen physical width | Screen density
 | Screen width in pixels
 | Screen width in dps
 |
1.5 in | 120 | 180 px | 240 dp |
1.5 in | 160 | 240 px |
1.5 in | 240 | 360 px |

**Window size classes** provide the foundation for top level layout decisions, but display-specific considerations are also needed.

## Display cutout

A display cutout is an area on some devices that extends into the display surface. It allows for an edge-to-edge experience while providing space for important sensors on the screen of the device. 

Applications can extend around display cutouts or other features, but some parts of the UI might be obscured.

_footer: A mobile device’s content-safe area around a display cutout for the front-facing camera_
_altText: Content safe area shown in portrait and in landscape mode._

## Foldable devices

Foldable devices use a folding mechanism to fold and unfold. They have unique characteristics to consider when designing layouts.

### Fold

The fold of a foldable device divides the screen into two portions, either horizontally or vertically. The fold can be a flexible area of the screen or, on dual-screen devices, a hinge that separates two displays.

A flexible fold is barely visible, although some users may feel a tactile difference on the screen surface. Content can flow over the fold fairly easily.

_footer: - Folds are typically found in the center of the device screen and can present a seamless experience_
_altText: Center fold of a foldable device layout._

On devices with a physical hinge, designing the screen as two distinct sections (separate window areas or panes) allows a composition to work well across the hinge and screens.

_footer: A physical hinge separates two parts. There is no display hardware in this region._
_altText: Center fold on a foldable device with a physical hinge._

### Device state

Foldable devices can have several physical states: folded, open flat, and tabletop.

#### Folded

The folded state can include a front screen, which often fits in the compact window size class, just like a mobile phone in portrait orientation.

_footer: The front screen of a foldable device_
_altText: Compact window of a folded device._

#### Open flat

An open flat state refers to the fully opened screen, which usually increases the window size class to medium or expanded. An open device can be used in landscape or portrait orientations.

_footer: In an open portrait state, the longer device edge is vertical while the shorter edge is horizontal_
_altText: Open portrait state of a mobile device._

_footer: In an open landscape state, the longer device edge is horizontal while the vertical edge is shorter_
_altText: Open landscape state of a mobile device._

#### Tabletop

Tabletop refers to a half-opened state forming a rough 90 degree angle, with one half of the device resting on a surface. This posture resembles a laptop.

UI controls near the fold can be difficult for users to access, and text overlaying the fold can be hard to read.

_footer: If camera hardware is present, a tabletop device is best positioned on a side without any protruding hardware elements_
_altText: Tabletop state of a mobile device showing camera ;ems  on the vertical plane._

### Interaction

#### App continuity

When running on a foldable device, an app can transition from one screen to another automatically. After the transition, the app should resume in the same state and location, and the current task should continue seamlessly.

_footer: A news app shows a feed in a compact and expanded window class when a foldable device switches device state_
_altText: A news app in compact mode compared to the open landscape state where the news app expands with a new column next to the compact news feed._

#### Scrolling and multiple panes

Depending on how your app uses panes, the scroll behavior of a folded design may change in the unfolded design. 

If you expand a pane, you can decide whether the whole window will scroll together or if each side (each pane) scrolls independently.

_footer: A single pane can scroll its inside content vertically and horizontally_
_altText: A foldable device screen in open landscape mode with a single pane showing vertical scroll arrows._

If your design has multiple panes, each pane can operate as an independently scrollable area.

_footer: Multiple panes can scroll inside content independently of one another_
_altText: A foldable device screen in open portrait mode with double panes each with a vertical scroll arrow._

## Multi-window mode

Multi-window mode is an Android system feature for **displaying multiple apps on the same screen.**This can be especially useful for multi-tasking, or workflows that depend on comparing information.

Note: This concept should not be confused with using multiple panes to display content from a single app. For more on that, see: Panes.

_footer: Screen displaying an email app and a contacts app in multi-window mode_
_altText: 2 apps appear side-by-side with a task bar below spanning the width of the screen._

### User needs

The ways that windows are created, arranged, and adjusted should feel straightforward for all users and across any window size class. Methods for seamless window management include:

- Apply smooth transitions as described in motion guidance
- Ensure that users can create multiple windows easily and move between them as needed
- Keep mental models and interaction patterns simple so that users aren’t required to think about which mode is appropriate for each task
- Design and implement window dynamics consistently across variations in foldable hardware, including those with a hinge that separates two displays

### Window creation and behavior

Android provides several ways for users to create a multi-window view.

### Taskbar

The taskbar provides a launching point for pinned and suggested apps to easily become a separate window. 

To create a new window, a user selects and drags an app from the taskbar and moves the app icon to indicate where the new window should be displayed.

_footer: Android taskbar_
_altText: The taskbar is positioned at the bottom of a screen._

### Context menu

Users can also create multiple windows through the overview by the app context menu.

_footer: Multi-window mode can have vertical positioning_
_altText: 2 apps appear side-by-side with a task bar below spanning the width of the screen._

_footer: Multi-window mode can have horizontal positioning_
_altText: 2 apps are stacked in landscape mode with a task bar below spanning the width of the screen._

### Adjusting window sizes

By default multiple windows are created as a 50/50 side-by-side split.

The windows can be adjusted further to 1:3 or 2:3 proportions. These ratios provide a primary and secondary window dynamic, offering greater flexibility and allowing focus on one application as needed.

When in a multi-window mode, the available screen area often changes from medium or expanded window class to compact. Layouts should adapt accordingly.

_footer: The screen handle can be dragged and released to create the desired window ratio. The handle automatically adjusts to the closest snap point._
_altText: 2 apps appear side-by-side with the left-side app using two-thirds of the screen, and the right app one-third._

[Over 2 billion people](https://www.w3.org/International/questions/qa-scripts.en.html) read and write in right-to-left (RTL) languages like Arabic, Hebrew, Farsi and Urdu. Layouts should support both left-to-right (LTR) and RTL languages through mirroring and other best practices to ensure content is easy for global audiences to understand and navigate. Consider the holistic experience including [global writing](/m3/pages/global-writing/overview#0d0f8403-e5ff-4579-be74-0c4dbcef7fcb), localizing voice and [design principles for culturally appropriate icons](/m3/pages/icons/designing-icons#1056d971-81ca-4abe-b931-42185dd76638). Material's components are built to support RTL, such as naming elements and tokens as "leading" and "trailing." However, extra configuration may be needed to achieve specific RTL situations.

## Mirroring

When a layout is changed from LTR to RTL (or vice-versa), and flipped horizontally, it’s often called mirroring. UI elements and text that typically appear on the left in LTR aligns to the right. Reading flow starts from the top right corner, instead of the top left.

Not all elements mirror with RTL languages. For example, graphs and charts maintain a LTR directionality for Persian and Urdu.

_footer: A mirrored layout in an RTL language reverses the alignment and ordering of elements._
_altText: Layout in LTR and mirrored for RTL language._

## Text rendering

Correct text rendering is foundational for a great user experience and it’s critical for readability and usability. Text rendering has two parts:

- Alignment: How the edges of the text box are placed alongside other elements.
- Directionality: How text and other elements flow within a text box, like left-to-right, or right-to-left.

In RTL languages, text is usually right-aligned, and elements flow from right-to-left.   Common issues with RTL language rendering are text entry, cursor position, punctuation, phone numbers, and URLs.   Improperly rendering text in RTL languages can create cognitive overload and negatively impact user sentiment and trust.

_footer: Don't reverse the order of the email username and domain (@google.com). The domain should always be to the right of the username.  Usernames can still be written RTL, with the cursor moving to the left.  Note this example is not translated to illustrate a common issue with text rendering_
_altText: Text field incorrectly displaying the word order of an email address and cursor placement._

_footer: Don’t apply LTR directionality to RTL content because it may scramble word order. To ensure readability across all languages. The content should have both RTL alignment and directionality.  Note this example is not translated to illustrate a common issue with text rendering_
_altText: Dialog window incorrectly displaying word order decreasing readability._

## Icons and symbols

In RTL languages, directional UI icons, like back and forward, should be mirrored. However, in Hebrew timelines and media controls on a page should retain left-to-right directionality.

The meaning of icons and symbols can vary significantly across cultures.

_footer: Back and foward icons are mirrored in RTL_
_altText: Back and forward icons in LTR and RTL._

_footer: Send buttons are mirrored in RTL. Help icons are mirrored in some RTL languages, like Urdu and Persian._
_altText: Send and question mark in LTR and RTL._

## Time

Linear representations of time are often mirrored in RTL language experiences. 

Linear progress indicators should move from right to left for most RTL languages, except Hebrew where it should remain LTR.

Circular representations of time remain the same.

_footer: - RTL linear progress indicator starts to fill progress from the right - Circular progress indicators move clockwise_
_altText: RTL linear progress indicators filling from right to left  and circular progress indicators filling clockwise ._

### Media players

Media controls for video or audio players are always LTR.

_footer: In Urdu, controls and progress for media and a podcast title are shown in LTR, while all other content is RTL._
_altText: Media player with control and progress in LTR and all other content is RTL._

### Clock

For RTL languages, the directionality of time remains LTR, and clocks still turn clockwise. However, the AM/PM symbols for 12h clocks should be placed to the left. The 24-hour clock is often used in countries where the primary language is not English.

Clock icons, circular refresh icons, and progress indicators with arrows pointing clockwise should not be mirrored.

_footer: 24-hour clocks in RTL move clockwise, but mirror elements such as buttons_
_altText: 24 hour clock in RTL._

_footer: 12-hour clocks in RTL move clockwise, but mirror UI elements such as AM/PM and buttons_
_altText: 12 hour clock in RTL._

## Canonical layout examples

### List-detail

The [list-detail](/m3/pages/canonical-layouts/list-detail) layout divides the app window into two side-by-side panes, and is mirrored in RTL.

_footer: List-detail mirrored for RTL, where text and other elements are aligned to the right and flow from right to left_
_altText: RTL list layout._

### Feed

Use a [feed layout](/m3/pages/canonical-layouts/feed) to arrange content elements like cards in a configurable grid for quick, convenient viewing of a large amount of content. The feed layout is mirrored in RTL.

_footer: Feed layout mirrored for RTL, where the order of text, grid, and other elements align to the right and flow from right to left_
_altText: RTL feed layout._

### Supporting pane

Use the [supporting pane](/m3/pages/canonical-layouts/supporting-pane) layout to organize app content into primary and secondary display areas. The supporting pane layout is mirrored in RTL.

_footer: Supporting pane to the left of the primary content. Text and other elements within the pane are aligned to the right and flow from right to left._
_altText: RTL supporting pane in a RTL language._

## Component examples

### Badges

Change the position and alignment of [badges](/m3/pages/badges/specs) for RTL languages.

_footer: Small badge appears on the top left of the icon_
_altText: Small badge on the top left of the icon._

_footer: Large badge appears on the top left of the icon_
_altText: Large badge on the top left of the icon._

### Toolbar

[Toolbars](/m3/pages/toolbars/guidelines) provide actions related to the current page. For RTL languages, mirror the order of the tools.

_footer: Mirrored floating toolbar, where the FAB appears on the left of the screen_
_altText: RTL floating toolbar_

### App bar

[App bars](/m3/pages/app-bars/overview) are placed at the top of the screen to help people navigate through a product.

Mirror app bar layout in RTL, and flip appropriate icons, such as arrows.

_footer: - RTL center-aligned/small - RTL medium flexible - RTL large flexible_
_altText: 3 app bars in RTL._

### Navigation drawer

[Navigation drawers](/m3/pages/navigation-drawer) that open from the side are always placed on the leading edge of the screen, on the left for LTR languages, and on the right for RTL.

_footer: RTL navigation drawer, including a mirrored icon for outbox_
_altText: RTL navigation drawer, including a mirrored icons._

### Navigation rail

The [navigation rail](/m3/pages/navigation-rail/guidelines) is placed on the leading edge of the screen, on the left side for LTR, and on the right for RTL.

_footer: Based on the language being used, a navigation rail is set on a screen’s leading edge. This is the right side for RTL languages, and left side for LTR languages._
_altText: Nav rail in the right side for RTL languages, and left side for LTR languages._

### Text fields

Icons in [text fields](/m3/pages/text-fields/guidelines#5c8a5f07-b1a5-455f-bf76-7ff0d724f6b0) are optional. Leading and trailing icons change their position based on LTR or RTL contexts.

_footer: Icons, symbols and label text for RTL:   - Icon signifier - Valid or error icon - Clear icon - Voice input icon - Dropdown icon - Image_
_altText: Text fields in RTL with leading and trailing icons._

### Chips

The leading icon of input chips can be an icon, logo, or circular image.

The trailing icon is always aligned to the end side of the container. It’s placed on the right for LTR and on the left for RTL.

_footer: Filter chips shown in an RTL layout. Note this example is not translated to help illustrate mirroring._
_altText: Filter chips in RTL layout._

## Swipe gestures

Gestures are the ways people interact with UI elements using touch or body motion.

People can navigate horizontally between peer views like tabs, and to complete actions. 

RTL swiping and gestures should mirror their counterparts in LTR. If an app includes a "delete" icon revealed when swiped from the right for LTR languages, the same should be possible on the left for RTL languages.

_footer: Swiping reveals additional action in RTL list layout_
_altText: RTL list layout with swipe gesture revealing additional actions._

On Android, [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows people to swipe left or right on the screen to go back or dismiss modal components.

RTL predictive back features should mirror those found in a LTR context.

_footer: Preview of the result of the gesture for RTL languages_
_altText: Back swipe for RTL languages. The back swipe on a bottom sheet takes user back to previous screen of a photo feed._

---

<!-- Source: m3.material.io · foundations_layout_breakpoints · updated 2026-07-17T04:55:59.912Z · CC-BY 4.0 (Google) -->

## Breakpoints

> Breakpoints ensure layouts work across a wide range of devices



<!-- section: Overview -->

Material uses breakpoints to create adaptive designs that work across devices:

-
There are five main breakpoints: compact, medium, expanded, large, and extra-large

-
Layouts typically transition from a single pane to two or three panes as window size increases

-
When moving across breakpoints, decide which elements to reveal, divide, resize, reposition, or swap

## Breakpoints overview

A breakpoint (previously window size class) is the window size at which a layout needs to change to match available space, device conventions, and ergonomics. These apply to Android and web.

All devices fall into one of five Material breakpoints:

-
Compact

-
Medium

-
Expanded

-
Large

-
Extra-large

Rather than designing for an ever-increasing number of display states, focusing on breakpoints ensures layouts work across a wide range of devices.

_footer: - Compact  - Medium  - Expanded_
_altText: 3 breakpoints from small to expanded._

Large and extra-large breakpoints are used on devices like laptops, desktops, and external monitors.

_footer: - Large  - Extra-large_
_altText: 2 devices with large and extra-large breakpoints._

**Design for breakpoints instead of specific devices because:**

-
The amount of available window space is dynamic and changes based on user behavior, such as multi-window modes or unfolding a foldable device

-
Devices fall into different breakpoints based on orientation

Breakpoint
 |
Width (dp)
 |
Common devices
 |

Compact
 |
Under 600dp
 |
Phone in portrait
 |

Medium
 |
600–839dp
 |
Tablet in portrait

Foldable in portrait (unfolded)
 |

Expanded
 |
840–1199dp
 |
Phone in landscape

Tablet in landscape

Foldable in landscape (unfolded)

Desktop
 |

Large
 |
1200–1599dp
 |
Desktop
 |

Extra-large
 |
1600dp+
 |
Desktop

Ultra-wide monitors
 |

### Height breakpoints

On Android, compact, medium, and expanded breakpoints are also available for [height](https://developer.android.com/develop/ui/compose/layouts/adaptive/support-different-display-sizes#window_size_classes). These can be used to adjust the layout when available vertical space is unusually small or large. However, since most layouts contain vertically scrolling content, it's rare that layouts need to adjust to available height.

## Designing across breakpoints

_footer: Products should automatically adapt to any breakpoint_
_altText: An email app shown at 3 breakpoints: compact, medium, and expanded._

_footer: A product’s layout should adjust to fit each breakpoint. For example, a large window can have two panes, while an extra-large window can have three._
_altText: 2 screens at large and extra-large breakpoints._

Each product view should have a layout for the breakpoints most appropriate for your platform and users.

Different components are recommended for performing the same function across the five layouts.

Breakpoint
 |
Panes
 |
Navigation
 |
Communication
 |
Action
 |

Compact
 |
1
 |
Navigation bar, modal expanded

navigation rail
 |
Simple dialog

Full-screen dialog
 |
Bottom sheet
 |

Medium
 |
1 (recommended) or 2
 |
Navigation bar, modal expanded

navigation rail
 |
Simple dialog
 |
Menu
 |

Expanded
 |
1 or 2 (recommended)
 |
Modal or standard expanded

navigation rail
 |
Simple dialog
 |
Menu
 |

Large
 |
1 or 2 (recommended)
 |
Modal or standard expanded

navigation rail
 |
Simple dialog
 |
Menu
 |

Extra-large
 |
1 to 3 (recommended)
 |
Modal or standard expanded

navigation rail
 |
Simple dialog
 |
Menu
 |

Start by designing for one breakpoint, then adjust the layout for the next size by asking these five questions:

### 1. What should be revealed?

Parts of the UI that are hidden on smaller devices can be revealed in larger layouts. 

For example:

-
On mobile, the navigation rail is collapsed by default

-
On an expanded device, the navigation rail can be open by default, revealing more actions and features

_footer: A product’s navigation rail can be revealed in an expanded layout_
_altText: Email app layouts in compact and expanded windows._

The same can be applied to [panes](/m3/pages/scaffold/panes). Larger layouts can simultaneously display an inbox pane and a pane containing a selected conversation. Additional space doesn’t just mean making the same thing bigger.

_footer: An expanded layout for a messaging app reveals a second pane with the selected conversation_
_altText: Messaging app layouts in compact and expanded windows._

### 2. How should a screen be divided?

When dividing a screen into layout panes, consider the breakpoint: 

-
Compact and medium breakpoints:  A single pane works best

-
Expanded and large breakpoints:  Two panes are recommended

-
Extra-large breakpoints: Consider using three panes

_footer: Compact and medium breakpoints should use a single pane, while larger breakpoints can use two_
_altText: A compact and medium window have a single pane. A larger window has 2 panes._

At medium breakpoints, two panes are useful when they contain low-density content with clear actions.  

Don’t use two panes in medium layouts with high information density, as it can reduce usability.

_footer: A settings view with low-density content and quick actions is a good use of two panes in a medium layout_
_altText: Medium window with 2 panes with low-density content: an email setting menu and a list of setting switches._

_footer: Rotating a device often changes the breakpoint. A layout can have two panes in landscape orientation, and one pane in portrait._
_altText: Video app in a medium window has 1 pane in portrait layout and 2 in landscape._

Single-pane layouts can focus attention on one action or view, creating a distraction-free environment for a specific goal such as:

-
Playing a game

-
Watching a movie

-
Video calls

-
Creative applications

_footer: Consider using an immersive single-pane layout for video calls_
_altText: Video app in a single-pane landscape layout at an expanded breakpoint._

### 3. What should be resized?

UI elements that are small on compact screens can grow as breakpoints increase. Panes can also expand to rearrange elements and make better use of space.

Consider resizing:

-
Cards

-
Feeds

-
Lists

-
Panes

Resizing can highlight imagery and improve text readability. This type of adaptation affects the scale of content and the relationship between objects on screen. For example, a vertical card on mobile can adjust its margins, orientation, text size, and density to better fit a tablet.

Across all breakpoints, adjust margins and type styles to keep text between 40–60 characters per line.

_footer: A small card in a compact layout can be resized larger in a medium or expanded layout_
_altText: 2 cards in compact and medium layouts. The image and text are rearranged and resized to be more legible in the medium layout._

### 4. What should be repositioned?

A UI and its components can reflow or reposition to make use of additional space on expanded screens and in resized panes. Repositioning is also a way to match the ergonomic and input needs that change across device sizes, such as shifting actions from the bottom of a compact window to the leading edge of medium and expanded windows. This method is similar to responsive design on the web.

Consider:

-
Repositioning cards

-
Adding a second column of content

-
Creating a more complex layout of photos

-
Introducing more negative space

-
Ensuring reachability for navigation and interactive elements

Internal elements can be anchored to the left, right, or center as a parent container scales. Internal elements can also maintain fixed positions, such as a floating action button (FAB) in a navigation rail.

_footer: Tabs can remain anchored to the middle of a layout at both compact and medium breakpoints_
_altText: Comparison of compact and medium breakpoints with tabs anchored to the middle of each layout._

In the case of a button, the icon and text label within the button container can remain anchored to each other, staying centered as the button container scales horizontally.

_footer: Button icons and label text can remain anchored to each other no matter the width_
_altText: Label text remains the same size and centered as button size increases._

### 5. What should be swapped?

As a layout changes across breakpoints, components with similar functions can also be exchanged. This makes it possible to adjust a layout for large-scale changes to the ergonomic and functional qualities of an interface.

For example, a bottom navigation bar in a compact layout can be swapped with a navigation rail in a medium layout.

_footer: Swap a navigation bar in a compact layout for a navigation rail in a medium or expanded layout_
_altText: A compact layout’s navigation bar becomes a navigation rail in an expanded layout._

Likewise, a navigation rail can swap from collapsed to expanded at larger breakpoints.

Use caution when swapping components. Make sure: 

-
The interchangeable components are functionally equivalent

-
The component swap serves a functional and ergonomic purpose

Don’t swap a button for a chip. Be careful when changing between list items and cards.

_footer: A collapsed navigation rail in medium or expanded layouts can become an expanded navigation rail in large or extra-large layouts_
_altText: A compact layout’s navigation rail expands in an extra-large layout._

_footer: Don’t arbitrarily swap components that aren’t functionally equivalent, such as swapping a button with a menu_
_altText: A button is swapped out for a menu in a food delivery app._

### Common swappable components

Component type
 |
Compact
 |
Medium
 |
Expanded
 |

Navigation
 |
Navigation bar
 |
Collapsed navigation rail
 |
Collapsed navigation rail
 |

Navigation
 |
Modal expanded navigation rail
 |
Modal expanded navigation rail
 |
Standard expanded navigation rail
 |

Communication
 |
Basic or full-screen dialog
 |
Basic dialog
 |
Basic dialog
 |

Supplemental selection
 |
Bottom sheet
 |
Menu
 |
Menu
 |

<!-- section: Compact -->

Layouts for compact breakpoints are for **screen widths smaller than 600dp.**

_footer: A compact breakpoint focuses on a single view_
_altText: Messaging app at a compact breakpoint._

## Navigation

Use a navigation bar or modal expanded navigation rail.

Place navigation components close to the edge of the screen where they’re easier to reach.

_footer: Place navigation elements near the bottom of a compact window so they’re easy to reach_
_altText: Navigation bar and FAB are close to the bottom of a mobile app in a compact window._

## Panes

Use a single pane in compact layouts.

_footer: - Single-pane layouts work best for compact breakpoints_
_altText: The single pane consumes most of the area in a compact window._

## Spacing

Margins are 16dp from the leading and trailing edge of the window.

_footer: In compact layouts, use 16dp margins_
_altText: The left and right margins of a compact window pane are 16dp._

## Special considerations

A compact layout will need to transition dynamically to a medium or expanded layout when:

-
A foldable device is unfolded

-
A mobile device is rotated from portrait to landscape

-
A tablet exits split-screen mode

-
A product is resized to be larger in multi-window mode

-
A free-form window is resized

_footer: Compact layouts should dynamically transition to larger layouts when a device is unfolded or rotated_
_altText: 2 mobile layouts showing a messaging app with a 1-pane list and an expanded navigation rail._

<!-- section: Medium -->

Layouts for medium breakpoints are for **screen widths from 600dp to 839dp.**

_footer: Single-pane layouts can focus attention on one action or view, such as a video call_
_altText: A medium breakpoint with a video call app in full-screen mode._

## Navigation

Place navigation components close to edges of the window where they’re easier to reach:

-
Single-pane layouts: Navigation rail

-
Two-pane layouts: Navigation bar

The navigation rail can be hidden in secondary destinations as long as the primary destination can still be accessed using a back button.

_footer: - Navigation area  - Single pane_
_altText: The navigation area of a medium breakpoint is a vertical bar at the leading edge, beside a single pane._

## Panes

### Single-pane layout

In a medium layout, a single pane is recommended because of limited screen width.

_footer: - A single-pane layout is recommended for medium breakpoints_
_altText: A single pane uses most of the space in a medium window._

### Two-pane layout

Limit use of two panes for content with lower information density, such as a settings screen.

Each pane in a two-pane layout should take up 50% of the window width. Avoid setting custom widths. A drag handle can be used to expand or collapse panes to be 100% of the window width.

_footer: Two-pane layouts should use 50% widths for each pane by default_
_altText: 2-pane layout in a medium window. Both panes fit 50% of the window width by default._

When adding navigation to a two-pane layout, use a navigation bar. This allows the panes to fully use the available window width.

_footer: Two-pane layout with:  - Navigation bar_
_altText: A navigation bar extends over 2 panes at the bottom of a medium window._

## Spacing

Medium layouts have margins of 24dp.

The spacer between panes is also 24dp.

_footer: Use 24dp for margins and spacer in a medium layout_
_altText: 2 pane layout with 24dp margins and 24dp space between panes._

## Special considerations

A medium layout will need to transition dynamically to a compact or expanded layout when:

-
A foldable device is folded

-
A tablet is rotated from portrait to landscape

-
A product goes from full-screen to split-screen

-
Multi-window mode is initiated

-
A free-form window is resized

_footer: Think of how a medium layout should change to a compact or expanded layout_
_altText: Email app with 2 panes at  a medium breakpoint._

### Reachability

For horizontal tablets and unfolded foldables, the top 25% of the screen is likely out of reach, unless the grip is adjusted. To accommodate device and hand sizes, limit the amount of interactions that are placed in the upper 25% of the screen.

_footer: - Limit interactions in the upper quarter of a screen, as they can be hard to reach_
_altText: The hard-to-reach top quarter of a medium breakpoint in landscape mode._

Avoid placing essential interactive elements too close to the bottom edge of the screen. Some users, particularly those with larger hands, might struggle to reach this area.

Specify interactions in a layout with these ergonomic regions in mind:

-
Users can reach this area by extending their fingers, which makes it inconvenient

-
Users can reach this area comfortably

-
Reaching this area is challenging when holding the device

_footer: Medium breakpoint ergonomic regions:   - Inconvenient  - Comfortable  - Challenging_
_altText: The 3 ergonomic regions of a medium breakpoint._

<!-- section: Expanded -->

Layouts for expanded breakpoints are for **screen widths from 840dp to 1199dp.**

_footer: Two-pane layouts are often best for expanded breakpoints_
_altText: Supporting pane layout of a video app. The large, primary pane has the video, title, and actions. The secondary pane has queued videos._

## Navigation

Place navigation components close to edges of the window where they’re easier to reach. Use a navigation rail, either collapsed or expanded.

The navigation rail can be hidden in secondary destinations as long as the primary destination can still be accessed using a back button.

For sorting, filtering, or secondary navigation, use tabs or other components directly in the pane.

_footer: - Navigation area  - Single pane_
_altText: The navigation area is a vertical bar at the left of the screen. To its right, the body pane fills the rest of the window._

## Panes

Use a single-pane or two-pane layout.

A two-pane layout is often best for expanded breakpoints. However, a single-pane layout can work when displaying visually- or information-dense content, such as videos.

_footer: At an expanded breakpoint, reserve single-pane layouts for information-dense content_
_altText: A single pane covers most of the expanded screen except for the navigation area and margins._

When using a [fixed-and-flexible](/m3/pages/scaffold/panes#92371c3b-587d-4c6f-8105-05b69dcec81a) layout, the fixed pane should have a width of 360dp by default.

_footer: In a fixed-and-flexible layout, the fixed pane is 360dp by default_
_altText: A 2-pane layout at an expanded breakpoint. The fixed pane starts at 360dp, then expands to a single-pane layout._

A [split-pane layout](/m3/pages/scaffold/panes#dc7982b7-754c-410a-9e88-18a54557c87b) uses two flexible panes and visually centers the spacer by default.

_footer: The navigation and first pane are 50% of the window width to keep the spacer visually centered_
_altText: A nav rail and a pane fill 50% of the window. A second pane fills the remaining 50%._

## Spacing

Expanded layouts have a leading and trailing margin of 24dp.

The spacer between panes is 24dp.

_footer: Use 24dp for margins and spacer in an expanded layout_
_altText: 2 pane layout with 24dp margins and 24dp space between panes._

## Special considerations

An expanded layout will need to transition dynamically to a compact or medium layout when:

-
A foldable device is folded

-
A tablet is rotated from landscape to portrait

-
The app goes from full-screen to split-screen

-
Multi-window mode is initiated

-
A free-form window is resized

_footer: Consider how an expanded layout should change at medium and compact breakpoints_
_altText: Email app moves from 2-pane expanded layout to medium to 1-pane small layout._

<!-- section: Large & extra-large -->

These breakpoints are most useful for creating web experiences tailored to laptop and desktop devices. Some products may not need large and extra-large breakpoints. Consider your platform’s conventions and users when making decisions on which breakpoints to design for.

-
Layouts for large breakpoints are for screen widths **from 1200dp to 1599dp**

-
Layouts for extra-large breakpoints are for screen widths of **1600dp and larger**

_footer: A two-pane layout is recommended for large and extra-large breakpoints_
_altText: Large window with a video app in 2 pane layout._

## Navigation

Use a navigation rail, either collapsed or expanded, depending on the amount of content.  

For sorting, filtering, or secondary navigation, use tabs or other components directly in the pane.

_footer: - Collapsed navigation area  - Single-pane layout_
_altText: Large web browser with a small navigation area on the leading edge with 1 pane filling the rest of the window._

An expanded navigation rail is best suited for extra-large windows, where there's still plenty of room for content. Consider collapsing the navigation rail when space is needed, or when on pages deeper in the page hierarchy.

_footer: - Expanded navigation area  - Single-pane layout_
_altText: Extra-large web browser with an expanded navigation area and 1 pane filling the rest of the window._

## Panes

A two-pane layout is often best for large and extra-large breakpoints.   

However, a single-pane layout can work when displaying visually- or information-dense content, such as videos.

_footer: Only use a single-pane layout for dense content or media_
_altText: The single pane covers most of a large screen except for the navigation area and margins._

When using a [fixed-and-flexible](/m3/pages/scaffold/panes#92371c3b-587d-4c6f-8105-05b69dcec81a) layout, the fixed pane should have a width of 412dp by default.

_footer: Fixed panes should be 412dp in large and extra-large layouts_
_altText: A 2-pane layout with 1 pane fixed at 412dp._

When using a [split-pane layout](/m3/pages/scaffold/panes#dc7982b7-754c-410a-9e88-18a54557c87b), the spacer should be visually centered by default, even when using an expanded navigation rail.

_footer: In split-pane layouts, navigation components shrink the leading pane, so the spacer remains centered_
_altText: An expanded nav rail and the first pane take up 50% of the window, and the second pane takes up 50%._

## Additional panes

The extra-large breakpoint supports using a standard side sheet as a third pane. When the side sheet is present, the navigation rail can remain visible, collapse, or hide completely. Don't use more than three panes.   

Note: Fixed panes in this window size are recommended to be 412dp, but side sheets have a default maximum width of 400dp.

_footer: - Standard side sheet (third pane)_
_altText: Extra-large window with 2 panes and a side sheet acting as a third pane._

## Spacing

Large and extra-large layouts have a leading and trailing margin of 24dp.

The spacer between panes is 24dp.

_footer: Use 24dp for margins and spacers in large and extra-large layouts_
_altText: 2 pane layout with 24dp margins and 24dp space between panes._

## Special considerations

Large and extra-large layouts will need to transition dynamically to a smaller layout when:

-
The app goes from full-screen to split-screen

-
Multi-window mode is initiated

-
A free-form window is resized

Pay attention to typographic elements such as line length to ensure readability on large and extra-large layouts.

_footer: Consider how a large layout should change at smaller breakpoints_
_altText: An email app with 2 panes in a large layout._

---

<!-- Source: m3.material.io · foundations_layout_grids-spacing · updated 2026-07-17T05:07:21.447Z · CC-BY 4.0 (Google) -->

## Grids &amp; spacing

> Grids and spacing organize content and actions for any layout



<!-- section: Overview -->

-
Grids create a consistent foundation and adapt across breakpoints (previously window size classes)

-
Use spacing to group related information and direct people’s attention to key actions

-
Density helps people see and compare more information in data-heavy views

_footer: Layouts in Material are based on a grid that adapts across all screen sizes_
_altText: Mobile and desktop UIs with grid lines._

## Availability & resources

Type
 |
Resource
 |
Status
 |

Design
 |
[M3 Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460)
 |
Available
 |

[Spacing system & tokens](/m3/pages/spacing/overview)
 |
Available
 |

Implementation
 |
[Jetpack Compose: Rulers](https://developer.android.com/reference/kotlin/androidx/compose/ui/layout/Ruler)
 |
Available
 |

## What’s new

##### **May 2026**

-
How to use grids and rulers to adapt layouts across devices

-
Expressive spacing guidelines

_footer: As screen size increases, additional columns allow for a richer layout_
_altText: Tablet with content divided into 8 columns. Each pane of content is 4 columns wide._

<!-- section: Grids -->

-
Layouts in Material are based on a grid that adapts across all breakpoints (previously window size classes)

-
Parts of the layout scaffold like rails and panes are positioned on this grid to create consistent adaptive layouts

-
The structure and spacing values used in a grid can add personality to a product’s layout

## How to use grids

### Start with placing grid columns

Grids adapt across breakpoints. As the size increases, column count, width, and spacing change as well.

_footer: The number and size of columns changes based on breakpoints_
_altText: A mockup of grid columns, showing compact, medium/expanded, and large/extra-large breakpoints._

When moving between sizes, column count may increase to show more content or controls.

_footer: On compact screens, fewer columns are used to create a focused layout_
_altText: A course listing on a compact screen, with 4 columns._

_footer: As screen size increases, for example when a foldable screen is unfolded, additional columns allow for a richer layout_
_altText: A course listing on a foldable screen, with 8 columns._

### Place bars & rails

Populate regions of the layout scaffold that are closest to the edges of the screen’s usable space first. This may include:

-
Bars like the navigation bar and rail

-
Components like toolbars and app bars

_footer: The bar region can contain a toolbar_
_altText: A compact screen with a toolbar highlighted._

_footer: The rail region on larger screens usually contains a navigation rail_
_altText: A large screen with a leading navigation rail highlighted._

### Place panes

Next, populate the main region of the screen with panes with content and components, based on available space and structure.

See the [canonical layout examples](/m3/pages/canonical-examples) for ideas on which panes are appropriate for a product.

_footer: - Primary pane  - Supporting pane_
_altText: Mobile UI with 1 pane. Foldable UI with 2 panes in a supporting pane layout._

## Rulers & alignment

Rulers are a set of recommended global alignment lines that help create consistent focal points in a product, while keeping content and components consistently aligned.

[How to implement rulers in Compose](https://developer.android.com/reference/kotlin/androidx/compose/ui/layout/Ruler)

_footer: - Margin  - Bar or safety region  - Title  - Content 1  - Content 2  - Content 3  - Content 4  - Bar or safety region  - Rail_
_altText: 1 compact and 1 desktop UI mapping rulers._

### Bar & safety rulers

Bar and safety rulers reserve space for [system UI](https://developer.android.com/training/system-ui) elements like the status bar and gesture navigation.

They ensure actionable content like app bars aren’t covered by system UI.

_footer: Bar and safety rulers align to the edges of a screen’s usable space, providing a reference for where system UI like the status bar or gesture navigation appear_
_altText: 2 mobile UIs showing bar and safety rulers at the top and bottom._

### Title rulers

The title ruler creates consistency for the screen’s title, aligning the text, icons, and other components in an app bar.

_footer: The title ruler aligns with the title in an app bar_
_altText: 1 mobile and 1 desktop UI showing title rulers._

### Content rulers

Use content rulers to align and anchor key content, such as headlines and carousels.

-
First content ruler: Emphasizes major blocks like hero images, headlines, or primary components

-
Secondary rulers: Determine where supplementary text or actions begin

_footer: Content rulers offer flexible alignment options to help create a consistent layout across a product_
_altText: 1 mobile and 1 desktop UI showing content rulers._

_footer: Realigning primary components or content to a content ruler can create strong hierarchy and visual rhythm across a product_
_altText: Carousel and text resizing to align with content rulers, creating a structured layout._

### Ruler options

Margin rulers come with some wiggle room to determine how tight or loose a product’s content feels on-screen. The standard ruler can be adjusted to the left or right.

Choosing a narrower or wider margin can create or remove negative space, or create expressive moments in a content-forward product.

_footer: Margin rulers can adjust to create more or less negative space_
_altText: Mobile UI showing a recipe layout where text margins narrow while the hero photo expands._

Rulers can also be used to create more immersive experiences. For example, a photo grid can take the full width of the screen, while components like search use wider margins.

_footer: Rulers allow components and media to use different margin widths_
_altText: Mobile UI for a photo app showing a full-width image grid and a search bar with wide margins._

<!-- section: Spacing -->

-
Spacing helps group content, direct attention, and shape the personality of a product

-
A denser layout can feel more serious and focused, while a more spacious layout can feel calm and open

-
Material’s spacing system can adapt to breakpoints and density settings. [More on the spacing system](/m3/pages/spacing/overview)

_footer: Desktop layouts can use more generous spacing than mobile layouts_
_altText: 2 screens: 1 mobile with tight spacing, 1 desktop with wider spacing._

## Spacing to group content

Grouping connects related elements that share context, such as an image and its caption. Use spacing to visually tie elements together and establish boundaries between unrelated items.

_footer: Placing a caption under an image creates an implicit group_
_altText: Photo of dumplings with a caption reading “restaurants in the area”._

**Explicit grouping** uses visual boundaries like outlines, dividers, and shadows to group related elements in an enclosed area.

It can also indicate that an item is interactive, such as:

-
List items between dividers

-
A card displaying an image and its caption

_footer: Outlines define clear boundaries to explicitly group elements_
_altText: A contact grouped in an outlined card with a photo and caption._

**Implicit grouping** uses close proximity and open space (rather than lines and shadows) to group related items.

For example, the items in a carousel are placed close together, with space around the composition to separate them from other content.

_footer: Close spacing implicitly groups carousel images_
_altText: Carousel of food-related photos._

## Spacing to direct attention

Use rhythm, similarity, and other grouping principles to distinguish and highlight important elements.

### Rhythm

Consistent spacing between related elements or groups makes them easier to navigate with the eye.

_footer: Cards should maintain consistent horizontal spacing to establish a strong rhythm when their height varies_
_altText: 4 art courses in a row of cards with consistent horizontal spacing and different heights._

### Similarity

Similar elements should have the same spacing and sizing in a layout to show they’re related.

Leading elements like thumbnails, avatars, or icons should always be aligned.

_footer: Thumbnails in a shopping basket should use identical sizes and styles to signal that each one represents a product, even if the original photos have different aspect ratios_
_altText: 3 shopping basket list items with the same thumbnail sizes and text styles._

### Proximity

Place components near each other to create cohesive groups. This helps people understand the relationships between information and actions.

For example, buttons should be close to the content they’re affecting.

_footer: Placing two buttons as a group near content implies they’ll both affect it in similar ways_
_altText: Email message with Reply and Reply all buttons positioned close together._

### Continuity

Place related elements in a container, row, or column to establish a clear group or relationship.

_footer: Use a row of chips to signal a single, unified control_
_altText: Clothing product page with a horizontal row of size chips, with 6 selected._

## Spacing as expression

Give the most important content, tasks, or actions visual prominence with generous spacing and the brightest surfaces.

### Focal points

Consistent placement of key actions and information helps build recognizable focal points across a product.

_footer: Carousel images, categories, and titles should appear in a consistent location across pages_
_altText: 2 mobile screens showing carousels with identical layouts and title placement._

### Negative space

Allow negative space to give form and meaning to elements on screen. Framing important actions or content with generous spacing creates emphasis.

_footer: Negative space gives shape and emphasis to the course header_
_altText: A mobile screen shows  generous negative space around carousel images._

<!-- section: Density -->

-
Information density is the consideration of the amount of information visible on the screen

-
The default target size should be at least 48x48 CSS pixels

-
People can change density as long as the density controls are accessible

-
Apply density thoughtfully; not every layout needs it

-
Layout and component scaling (component adaptation or component density) can allow people to scan, view, or compare more information at once

_footer: Information density can change based on context and preference_
_altText: A website design with a denser arrangement of text and graphics._

_footer: Consider whether components should scale_
_altText: 5 components scaling with multiple size examples._

**Information density**

-
Information density can be achieved through layout and design decisions without using component scaling

-
Some people may not benefit from increased density

**Component scaling**

-
Components can adapt and change dimensions to help people scan, view, or compare different amounts of information

-
Don't apply component scaling by default if it would result in a target below 48x48 CSS pixels

_footer: Information density and component scaling can be used together to provide more information and additional user control_
_altText: An email app with “Appearance settings” open to change information density between cozy, comfortable, and compact._

## Information density

Information density refers to the amount of content (such as text, images, or videos) in a given space.

A layout’s spacing dimensions, including margins, spacers, and padding, can change to increase or decrease its information density. High density layouts are useful when people need to scan, view, or compare a lot of information, such as in a data table. Increasing the layout density of lists, tables, and long forms makes more content available on-screen.

Consider density settings in the context of a device. Although a person may prefer a denser layout for desktop, they may not for mobile. Density shouldn’t automatically change across breakpoints or orientation unless a person changes it.

_footer: Consider using higher density information design when people need to scan lots of information_
_altText: 2 layouts: 1 with low density and 1 with high density._

_footer: Consider the amount and priority of information on-screen. Higher density can be useful for data-rich products where people expect to scan lots of information quickly. Examples: News, financial portals, dashboards_
_altText: News website on desktop displaying a high information density._

_footer: Lower density can be better for sites prioritizing aesthetics, a focused message, less information, or easier navigation_
_altText: News website on desktop displaying a low information density._

## Component scaling

The component density scale controls the internal spacing of individual components.

The density scale is numbered, starting at 0 for a component’s default density. The scale moves to negative numbers (-1, -2, -3) as space decreases, creating higher density.

Higher density is typically applied by decreasing the top and bottom padding or overall height by 4dp.

_footer: Apply component density based on the needs and layout of a design_
_altText: 3 buttons with densities  of 0, -1, -2._

Center the grouped element within the component container.

Text size shouldn’t change as the container size scales.

_footer: The measurement between the label and input is 20dp_
_altText: Text field showing 20dp between label and input_

_footer: The label and input are centered within their parent container_
_altText: Parent container showing label above input._

_footer: Don’t increase density in UIs that involve focused tasks, such as selecting from a menu. It reduces usability by limiting selectable space._
_altText: Dropdown menu with high density items and selectable space height of 38dp._

_footer: Don't increase the density in components that alert a person of changes, such as snackbars or dialogs_
_altText: Single-line snackbar with high density._

### Avoid applying component scaling by default

People should be able to **opt in** to dense layouts and components.

To ensure density settings can be easily reverted, settings interactions must use default target sizes (48x48 CSS pixels).  

Don't scale layouts below 48x48dp by default.

_footer: People can opt in to dense layouts in settings_
_altText: A density menu with large, medium, and small options to customize the screen layout of a table on desktop._

## Targets

Dense components can be less accessible because interactive elements are smaller, so use caution when increasing information density.

_footer: Use caution when applying component scaling where selectable targets will be reduced to less than 48x48dp. Only apply density where it provides a better experience._
_altText: Selectable target of only 40dp._

Use caution when applying density to interaction targets. Accessible targets should retain a minimum of 48x48dp, even if the visual element, such as an icon, is smaller.

_footer: The target should remain 48x48dp, even if the icon is smaller_
_altText: Settings button icon is 24x24dp, but has interaction target of 48x48dp._

_footer: The interaction target of a common button can be larger, as long as it meets the 48x48dp minimum size_
_altText: Button with height of 36dp and interaction target of 48dp._

## Pixel density

Pixel density is the number of pixels per inch. High-density screens have more pixels per inch than low-density ones. Elements with the same pixel dimensions appear larger on low-density screens and smaller on high-density screens.

To calculate pixel density:

Pixel density = Screen width (or height) in pixels / Screen width (or height) in inches

_footer: High-density elements have more pixels per inch_
_altText: Magnified UI element  showing a high number of pixels in the focus area._

_footer: Low-density elements have fewer pixels per inch_
_altText: Magnified UI element  showing a low number of pixels in the focus area._

### Density-independent pixels

Density-independent pixels, written as dp, are flexible units that scale to have uniform dimensions on any screen. They provide a flexible way to accommodate a design across devices. The Material design system uses density-independent pixels to display elements consistently on screens with different densities.

A dp is equal to one physical pixel on a screen with a density of 160.

To calculate dp:
dp = (width in pixels * 160) / screen density

_footer: Low-density screen displayed with density independence_
_altText: Screen with grid representing a low number of pixels._

_footer: High-density screen displayed with density independence_
_altText: Screen with grid representing a high number of pixels._

Screen physical width
 |
Screen density
 |
Screen width in pixels
 |
Screen width in dps
 |

1.5 in
 |
120
 |
180 px
 |
240dp
 |

1.5 in
 |
160
 |
240 px
 |

1.5 in
 |
240
 |
360 px
 |

---

<!-- Source: m3.material.io · foundations_layout_scaffold · updated 2026-07-17T05:27:27.930Z · CC-BY 4.0 (Google) -->

## Scaffold

> A fundamental UI design structure that provides a standard platform for assembling key components



<!-- section: Overview -->

-
The layout scaffold structures every piece of an adaptive layout into bars, rails, and panes

-
Bars can frame the page to help people navigate through a product

-
Rails create the perimeter space surrounding panes, creating space for elements like navigation and toolbars

-
Panes hold a product’s primary content, adapting to breakpoints (previously window size classes) and other conditions

## Availability & resources

Type
 |
Resource
 |
Status
 |

Design
 |
[M3 Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460)
 |
Available
 |
 |
[Spacing system & tokens](/m3/pages/spacing)
 |
Available
 |

Implementation
 |
[Jetpack Compose: Rulers](https://developer.android.com/reference/kotlin/androidx/compose/ui/layout/Ruler)
 |
Available
 |

_footer: - Safety region  - Bar  - Pane  - Rail_
_altText: 2 diagrams of mobile and desktop layouts, identifying the parts of a scaffold._

<!-- section: Bars -->

## Bars

Bars frame the screen to help people navigate through a product. They typically contain an app bar or bottom navigation bar.

Bars can span a single pane or across the full width of a window.

_footer: - A navigation bar occupies the bottom bar region on mobile  - An app bar occupies the top bar region on the web_
_altText: Navigation bar on mobile and app bar on desktop._

App bars are placed at the top of the screen to help people navigate, providing a title and 1–2 essential actions like search or back.

_footer: - The app bar sits at the top of the screen, outside of the safety region_
_altText: A photo app with an app bar below the safety region and above a grid of photos._

Navigation bars let people switch between 3–5 primary UI views at compact or medium breakpoints.

_footer: - The navigation bar sits at the bottom of the screen, above the safety region_
_altText: A photo app with a navigation bar below a grid of photos._

### Safety region

Bars are placed adjacent to the safety regions, which contain [system UI](https://developer.android.com/develop/ui/compose/system/system-bars) elements.

The safety region shouldn’t contain primary content.

_footer: - The safety region—at the top and bottom edges of the screen on compact devices—protect system UI elements_
_altText: A photo app with a safety region above an app bar and grid of photos._

<!-- section: Rails -->

## Rails

Rails are the next level in layout after bars, filling the perimeter space surrounding panes or floating above them.

_footer: Rails occupy the spaces immediately adjacent to bars:  - A toolbar sits above the navigation bar  - A navigation rail and companion rail occupy the leading and trailing sides of a large window_
_altText: Rail regions highlighted, a bottom toolbar on mobile, and a leading and trailing rail on desktop._

On compact screens, the top and bottom rail regions can be used for components like:

-
Toolbars

-
Chat inputs

-
FABs

-
Other primary controls related to an individual screen

_footer: - On mobile, a toolbar can float in the rail region_
_altText: A mobile photo app highlighting a toolbar above a navigation bar._

On larger screens, there are rails on the sides of the screen (as well as top and bottom). The leading side rail region commonly holds the navigation rail.

_footer: At larger breakpoints, the leading rail region can be occupied by an expanded navigation rail_
_altText: A photo app on desktop, highlighting an expanded navigation rail._

The rail region on the trailing side of a large screen can hold supporting controls or actions that modify or relate to the content in a pane.

_footer: The rail region can also be occupied by a vertical toolbar or other controls_
_altText: A photo app on desktop, highlighting a trailing vertical toolbar._

In [XR](/m3/pages/xr-design/overview/), rail components can become [orbiters](https://developer.android.com/design/ui/xr/guides/spatial-ui#orbiters), which float outside the visible content area.

_footer: In full space, an XR navigation rail can float outside the main content as an orbiter_
_altText: A photo app in immersive XR, with a navigation rail floating outside the pane._

<!-- section: Panes -->

## Panes

All layouts are made up of 1–3 panes. The type of layout and amount of panes you choose should depend on the breakpoint (previously window size classes) and the type of product being built.

_footer: Layouts often include multiple panes that work together_
_altText: A two-pane layout on desktop._

All layouts are made up of 1–3 visible panes. The type of layout and amount of panes you choose should depend on the breakpoint and the type of product you're building.

Breakpoint
 |
Recommended pane total
 |
Other pane totals
 |

Compact
 |
1
 |
--
 |

Medium
 |
1
 |
2
 |

Expanded
 |
2
 |
1
 |

Large
 |
2
 |
1
 |

Extra-large
 |
2
 |
1, 3
 |

Panes can be:

-
Fixed: Width doesn’t change based on available space

-
Flexible: Width changes based on available space, and can grow and shrink

All layouts need at least one flexible pane.

_footer: - Fixed pane  - Flexible pane_
_altText: A device with 2 panes: 1 fixed and 1 flexible._

Panes can be permanent or temporary. Temporary panes can appear and be dismissed when necessary, affecting the layout and size of other panes.

_footer: Panes can be displayed permanently side by side_
_altText: 2 permanent panes._

_footer: Temporary panes can be dismissed_
_altText: Right pane with a close button being dismissed. The left pane fills the available space._

### Single-pane layouts

Single-pane layouts use one flexible pane that extends to fit the available space in a layout’s width. They can be used at any breakpoint, but are recommended for compact and medium.

_footer: A single flexible pane adapts to fit any breakpoint_
_altText: A mobile screen with 1 flexible pane._

### Two-pane layouts

**Split-pane layout**

A split-pane layout keeps the spacer visually centered. It’s best for foldable devices and dynamic layouts.

When a navigation rail or drawer is present, it only reduces the size of one pane. The other pane remains at 50% of the window width.

_footer: The navigation and first pane should be 50% of the window width to keep the spacer centered_
_altText: 2 flexible panes in a split-pane layout._

With a navigation bar, or no navigation, both panes span 50% of the window width by default.

_footer: With no navigation rail visible, split-pane layouts set each pane to 50% width by default_
_altText: 2 flexible panes at 50% width, with a navigation bar below them spanning the whole window._

**Fixed-and-flexible layout**

This layout is common for expanded, large, and extra-large breakpoints. The fixed-and-flexible panes can appear in whichever order is best for the content.

The fixed pane is often temporary, and used for side sheets or lists with light information density.

_footer: - Fixed pane  - Flexible pane_
_altText: Fixed and flexible panes arranged 2 different ways._

### Three-pane layouts

While less common, the extra-large breakpoint supports using a standard side sheet as a third pane. When the side sheet is present, the expanded navigation rail can remain visible, change into a collapsed navigation rail, or hide completely. Don't use more than three panes. 

Note: Fixed panes at this breakpoint are recommended to be 412dp, but side sheets have a default maximum width of 400dp.

_footer: - A standard side sheet can be used as a third pane_
_altText: Extra large breakpoint with 2 panes and a side sheet acting as a third pane._

## Pane expansion & resizing

Panes can be resized, expanded, and collapsed using drag handles. 

-
In a split-pane layout, both flexible panes can be freely adjusted, or can snap to certain widths.

-
In a fixed-and-flexible layout, the drag handle can fully collapse and expand the fixed pane. This makes it easy to switch between a single-pane and two-pane layout.

The drag handle should also toggle between layout sizes when selected. This can be a tap, double tap, or long press.

_footer: Drag handles can adjust pane size in a list-detail layout_
_altText: A drag handle is used to collapse a two-pane layout into a single-pane layout._

At expanded, large, and extra-large breakpoints, two-pane layouts can be customized to snap to set widths when resized.

The recommended custom widths are:

-
360dp

-
412dp

-
Split-pane with spacer centered visually

_footer: Panes can snap to custom widths when releasing the drag handle_
_altText: A drag handle adjusts the panes to recommended custom widths._

### Persistent pane resizing

The persistent resizing behavior remembers a person's pane width preference. Use this for most resizable layouts.

_footer: Pane widths persist even after a person closes the app_
_altText: Resizing the panes and then resetting the app preserves the set width._

The width persists even after a breakpoint change. This means that if a two-pane layout is collapsed to one pane at any size, it’ll remain collapsed even when changing breakpoints.

_footer: When a two-pane layout is resized to a single full-width pane, that pane should remain at full-width after switching breakpoints_
_altText: Resizing the panes and then rotating a tablet back and forth preserves the set width._

### Temporary pane resizing

The temporary resizing behavior doesn't remember a person’s preferences for pane width. This is primarily used in supporting pane layouts where resizing is uncommon.

_footer: Supporting pane layouts can have a pane drag handle to temporarily resize the secondary content_
_altText: Resizing the panes and then closing the second pane resets the set width when expanded again._

With temporary resizing, panes should always return to the default layout after the pane or product is closed and reopened. This ensures content is a suitable size for most interactions.

_footer: The pane width can be temporarily adjusted using the drag handle, but will return to the default layout_
_altText: Layouts with temporary resizing reset any custom widths to the default._

## Displaying multiple panes

Multiple panes can be displayed in three ways: co-planar, floating, or docked. The layout depends on breakpoint, what the pane does, and how people interact with it:

-
Co-planar: Two side-by-side panes. To stay accessible, persistent utilities like tool panels should be co-planar with primary content.

-
Floating: A small pane displays above larger panes. Temporary tasks should remain floating regardless of breakpoint, such as a dialog.

-
Docked: A small pane pinned to the edge of a window. For example, a bottom sheet can be docked to show additional actions.

_footer: Co-planar: Panes are displayed side by side_
_altText: A foldable open screen with 2 co-planar panes displayed side by side._

_footer: Floating: A pane is displayed above other panes or content, like a dialog_
_altText: A foldable open screen with a floating pane displayed above other elements._

_footer: Docked: A pane is displayed above other panes and one of its edges extends beyond one side of the screen, like a bottom sheet_
_altText: A foldable open screen with a docked pane to the bottom of the screen displayed above other elements._

## How panes adapt

Pane layouts can adapt using three strategies: **show and hide, levitate,** or **reflow**. When a window is resized or changes orientation, these strategies allow panes to reorganize themselves to preserve context and meaning.

### Show and hide

As the breakpoint size or orientation changes, panes can enter and exit the screen or appear next to one another.

_footer: A pane can be shown or hidden depending on the available space and orientation_
_altText: 1 pane animates off-screen when the device is vertical, then reappears when horizontal._

### Levitate

Panes can be elevated above other content as **floating** or **docked** panes. This strategy helps panes appear relative to their triggers.

Floating panes:

-
Appear in front of the body content

-
Can be customized to be dragged or resized

When adding controls that resize or move a floating pane, provide accessible controls.

_footer: A co-planar pane can float when switching breakpoint or orientation_
_altText: 1 pane floats on top of the other when the device changes to a vertical orientation._

On large screens:

-
Floating panes are the default

-
The scrim behind a floating pane is optional

_footer: - Floating pane with a scrim  - Floating pane without a scrim_
_altText: 2 ways of showing floating panes on large screens, with and without a scrim._

Docked panes are usually at the bottom of the window, like a bottom sheet.

At medium and expanded breakpoints, docked panes can adapt into floating panes.

_footer: A docked pane can adapt into a floating pane at medium and expanded breakpoints_
_altText: A docked pane on mobile turning into a floating pane on desktop._

Alternatively, at medium and expanded breakpoints, a docked pane can adapt into a co-planar pane.

_footer: A docked pane can also adapt into a co-planar pane at medium and expanded breakpoints_
_altText: A docked pane on the lower half of a mobile screen changes to a co-planar pane on a larger screen._

On large screens, consider changing docked panes into co-planar panes.

_footer: - A compact screen can have a docked pane  - On a large screen, it should change to a co-planar pane_
_altText: A docked pane on mobile and a co-planar pane on a tablet._

### Reflow

Panes can be reorganized on screen as the breakpoint or orientation changes, also known as reflow.

For example, in a vertical orientation, the supporting pane can move underneath the primary pane.

_footer: In a vertical orientation, the supporting pane can move below the primary pane_
_altText: A supporting pane changes orientation and location as the screen changes orientation._

Reflow also applies to breakpoints. When there’s not enough horizontal space for panes, they can stack vertically instead.

_footer: Panes can change size, location, and orientation when switching screen sizes_
_altText: A supporting pane on the right side of a large horizontal screen moves to the bottom of a vertical small screen._

## Spatial panels

On XR devices, pane layouts can be presented in disconnected spatial panels. These panels must have clear containment to make them easy to see on any background.

The content in a spatial panel can use implicit grouping when the pane has an explicit container to distinguish it from the environment.

_footer: When a pane uses explicit containment, content can use implicit grouping_
_altText: 2-pane layout in XR with implicit content grouping and a virtual reality background._

## Accessibility considerations

**Coplanar panes**

-
The focus order should match the visual arrangement of the panes on screen

**Floating panes**

Modal floating pane:

-
When active, the elements behind it can’t be interacted with

-
Focus moves automatically to the first element in the pane, and when the pane is closed, focus moves back to the element that triggered it, like a dialog

-
If triggered automatically, focus should still move to it, but when it’s closed, focus should go to the next most logical element on screen

-
It disappears when a person interacts with something behind it.

Non-modal floating pane:

-
When open, other parts of a product can be interacted with

-
Focus should be able to move to and from the pane

-
The pane should be available in a logical reading order of the screen

**Docked panes**

-
Have the same focus requirements as modal and non-modal panes

-
The focus order should match the visual arrangement of the panes on screen

---

<!-- Source: m3.material.io · foundations_layout_canonical-examples · updated 2026-07-17T04:57:39.159Z · CC-BY 4.0 (Google) -->

## Canonical layout examples

> Canonical layout examples are designs for common screen layouts across all breakpoints



<!-- section: Overview -->

Canonical layout examples demonstrate how to implement the layout scaffold. They’re also available in code to provide a strong starting point for your product.

Each layout example considers common use cases and components to address expectations and user needs for how products adapt across breakpoints (previously window size classes).

_footer: A layout scaffold can include bar, rail, and pane regions_
_altText: A messaging app on desktop mapping bar, rail, and pane regions._

## Availability & resources

Type
 |
Resource
 |
Status
 |

Design
 |
[M3 Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460)
 |
Available
 |

Implementation
 |
[Jetpack Compose: Canonical layouts](https://developer.android.com/develop/ui/compose/layouts/adaptive/canonical-layouts)
 |
Available
 |

[Android Views (MDC-Android): Canonical layouts](https://github.com/android/user-interface-samples/tree/main/CanonicalLayouts)
 |
Available
 |

## Examples

There are three canonical layout examples: feed, list-detail, and supporting pane. Each example has configurations for compact, medium, and expanded breakpoints.

Use these canonical examples as a starting point to create layouts for a product.

### Feed

Use a feed layout to arrange elements like cards in a configurable grid for a quick, convenient view of a large amount of content.  

[More on feed layouts](/m3/pages/canonical-examples/feed/)

_altText: A course list in a feed layout at a medium breakpoint. 8 cards in a single pane, with bar above and leading rail._

### List-detail

Use a list-detail layout to display explorable lists of items alongside each item’s details. This layout divides the window into two side-by-side panes.

[More on list-detail layouts](/m3/pages/canonical-examples/list-detail/)

_altText: List-detail layout of a messaging app. Pane 1 lists all conversations. Pane 2 shows the selected message._

### Supporting pane

Use a supporting pane layout to organize content into primary and secondary sections:

-
Primary display area: Contains the main content and occupies the majority of the window (typically about two-thirds)

-
Secondary display area: Presents supporting content in a panel that takes up the remainder of the space

[More on supporting pane layouts](/m3/pages/canonical-examples/supporting-pane/)

_altText: Supporting pane layout. The primary pane shows course details. The  secondary pane lists “Lessons in this course”._

## Advanced custom layouts

To create a custom layout, build on top of canonical layouts or layer scaffold elements.

### Layering

Use the [levitate](/m3/pages/scaffold/panes#96bf71b8-04b8-4fff-97c7-9bc782fbf401) adaptive strategy to create a layered layout. Layering panes above other content can create a focused, task-oriented experience such as:

-
Reviewing a shopping basket

-
Responding to comments

-
Creating a calendar event

_footer: Layering panes helps people focus on a specific task_
_altText: Custom layout. A shopping basket floats above a clothing product page._

<!-- section: Feed -->

A feed layout uses a grid composition to enable quick content browsing and discovery. Key use cases include news, photos, and social media.

_footer: Feed layouts help people quickly browse and discover content_
_altText: Education app using a feed layout._

## Usage

Use a feed layout to show different pieces of content through cards and lists.

Feeds support displays of almost any size as grids can adapt from single to multi-column.

_footer: Feed layouts can adapt the number of columns across breakpoints_
_altText: An education app has 2 columns on mobile, and 4 columns on a tablet._

## Dividing space

A feed composition is flexible enough to allow for content with varying proportions and sizing.

_footer: Feeds can organize content of different sizes, like using small and large cards_
_altText: Feed layout in a medium window with 2 panes. 1 pane has 2 columns of small cards and the other has 1 large card._

Use size and position to establish relationships among content elements.  

Feed items should reflow when the amount of available space changes like:

-
Rotating or unfolding a device

-
Entering multi-window mode

The order of items is determined by their position.   

[More on adaptive design for cards](/m3/pages/cards/guidelines#99e8d17d-5bde-4bb9-8784-0ca403325b10)

_footer: Feed items can change size to group content_
_altText: Lead article image is prominent in a 2-pane news feed._

## Across breakpoints

### Compact

A feed layout should stack vertically, like a list of cards with individual items filling the width of the pane.

_footer: In compact windows, the cards in a feed stack vertically, filling the full width:   - Compact breakpoint  - Expanded breakpoint_
_altText: Cards in 2 feed layouts, compact and expanded._

### Medium

A feed layout can support components with different widths and be split across multiple columns.

_footer: Feed layouts can add columns in a medium window_
_altText: In a medium window, 4 equal-width columns of cards in a feed layout._

### Expanded, large, & extra-large

A feed layout can support components with different widths and be split across multiple columns. The number of columns should usually increase at expanded breakpoints.

_footer: Column width can increase at larger breakpoints_
_altText: Expanded window has wider columns than a compact window._

<!-- section: List-detail -->

Many layouts can be split into a list view and a detail view.

Key use cases for this layout include parent-child pairings of information like:

-
Text message + conversation

-
File browser + open folder

-
Musical artist + album detail

-
Settings + category detail

-
Email inbox + selected email

_footer: - List  - Detail_
_altText: An email app in a list-detail layout at a medium breakpoint._

## Usage

Use the list-detail layout for quickly accessing details of an item from a long list of content.  

Examples include:

-
Showing a series of conversations and a text message

-
Browsing files and seeing their details

-
Browsing multiple albums and seeing individual track information

_footer: Simplified diagram of:  - List area  - Detail area_
_altText: Several stacked cards make up the list area on the left pane, while the detail area is a single section on the right pane._

### Dividing space

_footer: The most basic list-detail views for compact, medium, and expanded layouts_
_altText: Compact windows have 1 pane, while medium and expanded windows can have 2 panes for list-detailed views._

A list-detail layout uses two panes.  Depending on the breakpoint, the two panes may appear together in the same layout or across separate layouts.  

List-detail layouts use the same pane guidance as all single and two-pane layouts, including special behavior for foldables.

**Breakpoint (dp)**
 |
**Visible panes**
 |

Compact (0-599)
 |
1 pane
 |

Medium (600-839)
 |
1 (recommended) or 2 panes
 |

Expanded (840+)
 |
2 panes
 |

Large (1200-1599)
 |
2 panes
 |

Extra-large (1600+)
 |
2 panes
 |

## Across breakpoints

### Compact

-
Use a single-pane layout

-
Only one view is visible at a time, either list or detail

_footer: - Phone in portrait orientation  - Closed foldable  - Tablet in split-screen mode_
_altText: Single-pane layout on 3 devices at compact breakpoints._

### Medium

-
Use a single-pane layout for information-dense content or deep focus

_footer: - Foldable open flat  - Tablet in portrait orientation_
_altText: Single-pane layout on a foldable open flat and a tablet in portrait orientation._

-
Use a two-pane layout to browse collections and switch between items quickly

-
To maximize horizontal space for two-pane layouts, use a bottom navigation bar or modal navigation rail

_footer: - Foldable open flat  - Tablet in portrait orientation_
_altText: 2-pane layout on a foldable open flat and a tablet in portrait orientation._

### Expanded, large, & extra-large

-
Use a two-pane layout

_footer: - Phone in landscape orientation - Tablet in landscape orientation_
_altText: 2-pane layout on a phone and tablet, both in landscape orientation._

## Behavior

### Single vs two-pane

-
Back button: Appears in detail view only for single-pane layouts

-
Selected state: Appears only in list view for two-pane layouts

-
Visual focus: Use [explicit and implicit grouping](/m3/pages/grids-spacing/spacing#e7e6d1ac-031a-4757-afcf-b223f23654ea) to direct focus in two-pane layouts

_footer: - Use a selection state in two-pane layouts only  - Use a back button in single-pane layouts only_
_altText: A 2-pane layout shows a selected list item. A single-pane layout uses a Back button to return to the list._

### Transitioning between layouts

The amount of available space is dynamic and changes based on how someone uses a device, such as rotating or unfolding it, or entering multi-window mode.

_footer: A two-pane layout adapts to a single-pane layout when a device rotates from an expanded to medium breakpoint_
_altText: Device rotating from landscape to portrait mode, reducing layout panes from 2 to 1._

#### No selected list item

A single-pane layout shows a list view, while a two-pane layout shows placeholder content in the detail pane.

In some cases, such as multi-select, the most recently used pane should stay visible when switching to single-pane layout.

_footer: If no item is selected when a foldable opens, the detail pane displays an empty state_
_altText: No item selected on a folded device. When unfolded, the detail pane is empty._

#### Selected list item

When switching from a single- to two-pane layout, both panes should be shown and the selected item’s details are visible.

When going from a two- to single-pane layout, the view depends on the product:

-
The detail pane should typically show in a single-pane layout, and an app bar appears

-
If the product supports selection without deep navigation, like multi-select, the list view can show with the item selected

-
Consistency is key: If a layout showed the list view previously, it should return to that view when returning to a single pane

_footer: If an item is selected when a foldable opens, the detail pane shows that item_
_altText: Item selected on a folded device. When unfolded, the detail view shows the item._

_footer: When a foldable closes with an item selected, the single pane shows the detail view_
_altText: Item selected on an unfolded device. When folded, only the detail view shows._

#### Persistent states

In most cases, a state should be saved when navigating between detail views. This includes read and unread content.

_footer: Detail views should retain their scroll position when navigating to other items_
_altText: Scroll position is kept after folding or unfolding the device._

<!-- section: Supporting pane -->

The supporting pane layout organizes content into primary and secondary areas.   

The primary area contains the main content and occupies the majority of the space. The secondary area contains supporting content.  

Key use cases for supporting pane layouts include:

-
Productivity

-
Document editing and commenting

-
Content and media browsing

_footer: Supporting pane layouts organize content into primary and secondary areas_
_altText: A video app has the main content in the primary area and “up next” content is listed in the secondary area._

## Usage

Use the supporting pane layout when the secondary content is only meaningful in relation to the primary content.   

For content with a parent-child relationship, use a [list-detail layout](/m3/pages/canonical-layouts/list-detail/) instead.

_footer: Supporting panes provide contextual info for the primary area_
_altText: The supporting pane has vertically stacked cards._

## Dividing space

The window is divided between a focus pane and a supporting pane.  

Depending on the breakpoint, the supporting pane may appear below or beside the focus pane.

_footer: Supporting panes can appear beside or below the primary area_
_altText: The cards of a supporting pane scroll horizontally across the bottom of the screen._

Supporting pane placement
 |
Pane width
 |
Breakpoint
 |

Below
 |
Flexible
 |
Compact or Medium
 |

Leading or trailing
 |
Fixed (360 dp)
 |
Expanded
 |

## Across breakpoints

### Compact

The supporting pane should appear below the focus pane. 

A bottom sheet can be useful for keeping focus on the primary pane while providing access to supporting information.

_footer: Bottom sheets can provide supporting information in compact windows_
_altText: 2 layouts showing  bottom sheets at a compact breakpoint._

### Medium

The supporting pane should appear below the focus pane.

_footer: Supporting panes appear below the focus pane in medium windows_
_altText: 3 cards in a supporting pane are horizontal across the bottom of a tablet._

### Expanded

The supporting pane should appear on the leading or trailing side of the focus pane.

_footer: Supporting panes appear beside the focus pane in expanded windows_
_altText: The supporting pane is to the right of the primary focus pane on 2 screens._

---

<!-- Source: m3.material.io · foundations_layout_bidirectionality-rtl · updated 2026-08-05T08:56:11.377Z · CC-BY 4.0 (Google) -->

## Bidirectionality &amp; RTL

> Design products that adapt to languages that read right-to-left (RTL)



<!-- section: Tab 1 -->

[Over 2 billion people](https://www.w3.org/International/questions/qa-scripts.en.html) read and write in right-to-left (RTL) languages like Arabic, Hebrew, Farsi, and Urdu. Layouts should support both left-to-right (LTR) and RTL languages through mirroring and other best practices to ensure content is easy for global audiences to understand and navigate. Consider the holistic experience including [global writing](/m3/pages/global-writing/overview), localizing voice and [design principles for culturally appropriate icons](/m3/pages/icons/designing-icons#5f0e344b-17f8-4b91-b0e4-45671b9900f4).

Material's components are built to support RTL, such as naming elements and tokens as "leading" and "trailing." However, extra configuration may be needed to achieve specific RTL situations.

## Mirroring

When a layout is changed from LTR to RTL (or vice-versa), or flipped horizontally, it’s often called mirroring. UI elements and text that typically appear on the left in LTR aligns to the right. Reading flow starts from the top right corner, instead of the top left.

Not all elements mirror with RTL languages. For example, graphs and charts maintain a LTR directionality for Persian and Urdu.

_footer: A mirrored layout in an RTL language reverses the alignment and ordering of elements_
_altText: Layout in LTR and mirrored for RTL language._

## Text rendering

Correct text rendering is foundational for a great user experience, and it’s critical for readability and usability. Text rendering has two parts:

-
Alignment: How the edges of the text box are placed alongside other elements

-
Directionality: How text and other elements flow within a text box, like left-to-right or right-to-left

In RTL languages, text is usually right-aligned, and elements flow from right-to-left.

Common issues with RTL language rendering are text entry, cursor position, punctuation, phone numbers, and URLs.

Improperly rendering text in RTL languages can create cognitive overload and negatively impact user sentiment and trust.

_footer: Don't reverse the order of the email username and domain (@google.com). The domain should always be to the right of the username. Usernames can still be written RTL, with the cursor moving to the left.  Note: This example isn’t translated to illustrate a common issue with text rendering._
_altText: Text field incorrectly displaying the word order of an email address and cursor placement._

_footer: Don’t apply LTR directionality to RTL content, because it may scramble word order. To ensure readability across all languages, the content should have both RTL alignment and directionality.  Note: This example isn’t translated to illustrate a common issue with text rendering._
_altText: Dialog window incorrectly displaying word order decreasing readability._

## Icons & symbols

In RTL languages, directional UI icons, like back and forward, should be mirrored. However, in Hebrew, timelines and media controls on a page should retain left-to-right directionality.

The meaning of icons and symbols can vary significantly across cultures. For additional guidance, refer to [design principles for icons](/m3/pages/icons/designing-icons#5f0e344b-17f8-4b91-b0e4-45671b9900f4).

_footer: Back and foward icons are mirrored in RTL_
_altText: Back and forward icons in LTR and RTL._

_footer: Send buttons are mirrored in RTL. Help icons are mirrored in some RTL languages, like Urdu and Persian._
_altText: Send and question mark icons in LTR and RTL._

## Time

Linear representations of time are often mirrored in RTL language experiences.

Linear progress indicators should move from right to left for most RTL languages, except Hebrew where it should remain LTR.

Circular representations of time remain the same.

_footer: - RTL linear progress indicator starts to fill progress from the right   - Circular progress indicators move clockwise_
_altText: RTL linear progress indicator filling from right to left and circular progress indicator filling clockwise._

### Media players

Media controls for video or audio players are always LTR.

_footer: In Urdu, controls and progress for media and a podcast title are shown in LTR, while all other content is RTL_
_altText: Media player with control and progress in LTR and all other content is RTL._

### Clocks

For RTL languages, the directionality of time remains LTR, and clocks still turn clockwise. However, the AM/PM symbols for 12h clocks should be placed to the left. The 24-hour clock is often used in countries where the primary language isn’t English.

Clock icons, circular refresh icons, and progress indicators with arrows pointing clockwise shouldn’t be mirrored.

_footer: 24-hour clocks in RTL move clockwise, but mirror elements such as buttons_
_altText: 24-hour clock in RTL._

_footer: 12-hour clocks in RTL move clockwise, but mirror UI elements such as AM/PM and buttons_
_altText: 12-hour clock in RTL._

## Canonical layout examples

### List-detail

The [list-detail layout](/m3/pages/canonical-examples/list-detail):

-
Is a single-pane at compact breakpoints, switching between list and detail views

-
Divides the window into two side-by-side panes on large screens

-
Is mirrored in RTL

_footer: List-detail mirrored for RTL, where text and other elements are aligned to the right and flow from right to left_
_altText: RTL list layout on mobile._

### Feed

Use a [feed layout](/m3/pages/canonical-examples/feed) to arrange content elements like cards in a configurable grid for quick, convenient viewing of a large amount of content. The feed layout is mirrored in RTL.

_footer: Feed layout mirrored for RTL, where the order of text, grid, and other elements align to the right and flow from right to left_
_altText: RTL feed layout._

### Supporting pane

Use the [supporting pane layout](/m3/pages/canonical-examples/supporting-pane) to organize content into primary and secondary display areas. The supporting pane layout is mirrored in RTL.

_footer: Supporting pane to the left of the primary content. Text and other elements within the pane are aligned to the right and flow from right to left._
_altText: RTL supporting pane in an RTL language._

## Component examples

### Badges

Change the position and alignment of [badges](/m3/pages/badges/overview) for RTL languages.

_footer: Small badge appears on the top left of the icon_
_altText: Small badge on the top left of a folder icon._

_footer: Large badge appears on the top left of the icon_
_altText: Large badge on the top left of an image icon._

### Toolbars

[Toolbars](/m3/pages/toolbars/overview) provide actions related to the current page. For RTL languages, mirror the order of the tools.

_footer: Mirrored floating toolbar, where the FAB appears on the left_
_altText: RTL floating toolbar._

### App bars

[App bars](/m3/pages/app-bars/overview) are placed at the top of the screen to help people navigate through a product:

-
Mirror an app bar’s layout in RTL

-
Flip appropriate icons, such as arrows

_footer: - RTL center-aligned, small app bars   - RTL medium, flexible app bar   - RTL large, flexible app bar_
_altText: 4 app bars in RTL._

### Navigation rail

The [navigation rail](/m3/pages/navigation-rail/overview) is placed on the leading edge of the screen, on the left side for LTR, and on the right for RTL.

_footer: Based on the language, a navigation rail is set on a screen’s leading edge:  - Right side for RTL languages  - Left side for LTR languages_
_altText: Nav rail on the right side for an RTL language, and left side for LTR._

### Expanded navigation rail

Expanded navigation rails that open from the side are always placed on the leading edge of the screen, on the left for LTR languages, and on the right for RTL.

_footer: RTL expanded navigation rails open from the leading edge and should include mirrored icons_
_altText: RTL expanded navigation rail, including mirrored icons._

### Text fields

Icons in [text fields](/m3/pages/text-fields/guidelines#5c8a5f07-b1a5-455f-bf76-7ff0d724f6b0) are optional. Leading and trailing icons change their position based on LTR or RTL contexts.

_footer: Icons, symbols, and label text for RTL:   - Icon signifier   - Valid or error icon   - Clear icon   - Voice input icon   - Dropdown icon   - Image_
_altText: Text fields in RTL with leading and trailing icons._

### Chips

The leading icon of input chips can be an icon, logo, or circular image.

The trailing icon is always aligned to the end side of the container. It’s placed on the right for LTR and on the left for RTL.

_footer: Filter chips shown in an RTL layout. Note: This example is not translated to help illustrate mirroring._
_altText: Filter chips with checkmark icons in RTL layout._

## Swipe gestures

Gestures are the ways people interact with UI elements using touch or body motion.

People can navigate horizontally between peer views like tabs and to complete actions.

RTL swiping and gestures should mirror their counterparts in LTR. If a product includes a delete icon revealed when swiped from the right for LTR languages, the same should be possible on the left for RTL languages.

_footer: Swiping reveals additional action in RTL list layout_
_altText: RTL list layout with swipe gesture revealing additional actions._

On Android, [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows people to swipe left or right on the screen to go back or dismiss modal components.

RTL predictive back features should mirror those found in a LTR context.

_footer: The predictive back gesture should adjust for RTL languages_
_altText: Back swipe for RTL languages. The back swipe on a bottom sheet takes person back to previous screen of a photo feed._
