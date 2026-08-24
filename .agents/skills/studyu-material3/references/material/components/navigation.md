# Material 3 · Navigation

<!-- Source: m3.material.io · components_navigation-bar · updated 2026-07-28T07:36:27.700Z · CC-BY 4.0 (Google) -->

## Navigation bar



<!-- section: Overview -->

-
Use navigation bars in compact or medium window sizes

-
Can contain 3-5 destinations of equal importance

-
Destinations don't change. They should be consistent across app screens.

_footer: Navigation bar for compact and medium window sizes_
_altText: Two navigation bars of different widths with 4 destinations._

## Availability & resources

## M3 Expressive update

**May 2025**

A new flexible navigation bar was introduced to replace the baseline navigation bar. It’s shorter and supports horizontal navigation items in medium windows. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
Baseline navigation bar is no longer recommended

-
Added **flexible**navigation bar

Shorter height

-
Can be used in medium window sizes with horizontal navigation items

Color:

-
Active label changed from **on-surface-variant** to **secondary**

_footer: The flexible navigation bar is shorter and can be used in medium windows with horizontal nav items_
_altText: Navigation bar in M3 Expressive. It’s shorter than the baseline nav bar._

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Elevation: No shadow
- Layout: Container height is taller
- States: The active destination can be indicated with a pill shape in a contrasting color
- Name: Bottom navigation has been renamed **navigation bar**

_footer: M2: A drop shadow indicates placement on top of content. Filled and regular weight icons indicate active states._
_altText: M2 nav bar with a drop shadow and no active indicator._

_footer: M3: Taller and no drop shadow. Filled icons and an active indicator indicate active state._
_altText: M3 nav bar with a surface color and active indicator._

<!-- section: Specs -->

## Variants

_footer: - Flexible navigation bar_
_altText: The recommended flexible navigation bar._

### Baseline variants

The baseline nav bar is no longer recommended, and should be replaced by the flexible nav bar, which is shorter and supports horizontal navigation items in medium windows. [View baseline nav bar specs](/m3/pages/navigation-bar/specs#46dc2521-acf0-44e3-bbc0-78dc225b9749)

_footer: - Navigation bar (not recommended)_
_altText: 1 baseline navigation bar._

Variant
 |
M3
 |
M3 Expressive
 |

Flexible navigation bar
 |
--
 |
Available
 |

Navigation bar
 |
Available
 |
Not recommended.

Use **flexible navigation bar**.
 |

## Configurations

In compact windows, navigation bars use vertical items. In medium windows, navigation bars should use horizontal items.

_footer: - Vertical navigation items - Horizontal navigation items_
_altText: Two size configurations for navigation bar and items._

Category

 |
Configuration

 |
M3

 |
M3 Expressive

 |

Navigation item layout

 |
Vertical (default)

 |
Available

 |
Available

 |

Horizontal

 |
--

 |
Available

 |

## Tokens & specs

Use the table's menu to switch between token sets for the navigation bar and the nav items. [](/m3/pages/navigation-bar/specs#3425f33a-0b11-492a-ae5a-40d63f939384)[Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: - Container - Icon - Label text - Active indicator - Small badge (optional) - Large badge (optional) - Large badge label_
_altText: Seven elements of the navigation bar._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Navigation bar color roles used for light and dark schemes:  - Surface container - On-secondary container - Secondary - Secondary container - On-surface variant - On-surface variant_
_altText: Six color roles of the navigation bar._

For badge color roles, go to [badge specs](/m3/pages/badges/specs).

## States

States are visual representations used to communicate the status of a component or an interactive element.

_footer: - Enabled - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: Four states of the navigation bar items._

## Measurements

The navigation bar stretches the full window width.

_footer: Navigation bar padding and size measurements_
_altText: Navigation bar padding and size measurements._

Vertical navigation items dynamically change width to equally fit the container. Horizontal navigation items have a fixed width, so extra space is added to the ends of the navigation bar instead.

_footer: Navigation bar width and margins for compact and medium windows.  - Vertical navigation item - Margin from window edge - Horizontal navigation item_
_altText: Navigation bar and item widths._

## Baseline navigation bar

_footer: - Container - Icon - Label text - Active indicator - Small badge - Large badge - Large badge label_
_altText: 7 elements of baseline navigation bar._

### Tokens & specs

These tokens are for the baseline navigation bar.

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Navigation bar color roles used for light and dark schemes:  - Surface - On secondary container - On surface - Secondary container - On surface variant - On surface variant_
_altText: 6 color roles of baseline navigation bar._

For badge color roles, go to [badge specs](/m3/pages/badges/specs).

### States

States are visual representations used to communicate the status of a component or an interactive element.

_footer: Navigation bar states:   - Enabled  - Hovered  - Focused  - Pressed_
_altText: 4 states of baseline navigation bar._

## Measurements

_footer: Navigation bar padding and size measurements_
_altText: Baseline navigation bar padding and size measurements._

_footer: Navigation bar target size and margins_
_altText: Baseline navigation bar target size and margins._

## Configurations

_footer: - 3 destinations - 4 destinations - 5 destinations_
_altText: 3 configurations of the baseline navigation bar._

<!-- section: Guidelines -->

_footer: Navigation bars adapt to different breakpoints_
_altText: A nav bar with vertical items in a compact window, and horizontal items in a medium window._

## Usage

Navigation bars provide access to three to five destinations. The nav bar is positioned at the bottom of windows for convenient access.

Each destination is represented by an icon and label text. One navigation destination is always active.

When a navigation bar icon is tapped or focused, people are taken to the navigation destination associated with that icon.

_footer: Navigation bars can have three to five destinations_
_altText: A nav bar for a music app with 4 destinations: Home, Browse, Radio, Library, It’s in a compact window._

Navigation bars should be used for:

- Three to five main pages in the product
- Mobile or tablet only

Navigation bars shouldn’t be used for accessing single tasks, such as viewing one email.

_footer: On mobile or tablet, navigation bars should be used for top-level destinations_
_altText: A nav bar for a music app with 4 destinations: Home, Browse, Radio, Library. It’s in a medium window._

The navigation items can be **vertical** or **horizontal**.

-
Use vertical items in compact windows, like mobile

-
Use horizontal items in medium windows, like tablets

_footer: Vertical navigation items work best in compact windows. Horizontal items work best in medium windows._
_altText: A nav bar with vertical items in a compact window, and horizontal items in a medium window._

For products with more than five navigation items, don’t use a navigation bar; the elements may collide and there likely won’t be enough space for translated text.

Instead, consider using tabs to organize similar content within a page, or hide the navigation behind a menu icon using a modal expanded navigation rail.

_footer: Avoid putting more than five navigation items in a navigation bar_
_altText: A nav bar with 7 items in a compact window._

_footer: Don’t remove the labels from navigation items_
_altText: A nav bar with no labels for each page item._

_footer: Don’t use a navigation bar for fewer than three destinations. Instead, use tabs._
_altText: A nav bar with 2 page items._

_footer: Use navigation for distinct pages and tabs for related content within a page_
_altText: A nav bar is on the Library page of a music app. Tabs at the top of the page have secondary navigation for playlists, artists, albums, and songs._

_footer: Navigation bar destinations have fixed positions. Don’t scroll them or modify their positions._
_altText: Nav bar using horizontal items in a compact window. The items are too wide and flow off screen._

## Anatomy

_footer: - Container - Icon - Label text - Active indicator - Large badge (optional) - Small badge (optional)_
_altText: 6 elements of the nav bar._

### Container

The container should always be placed at the bottom of the product and span the full length of the window. Navigation items are centered within the container.

The container has a color fill to provide separation from other content.

_footer: The navigation bar container holds all elements_
_altText: The nav bar at the bottom of a medium window has a color fill to differentiate from the background._

### Navigation items

Navigation items hold all elements for each destination: the icon, label text, and active indicator. They can be **vertical**, with the text below the icon and indicator, or **horizontal**, with the icon and text beside each other inside the indicator. 

Vertical items are best in compact windows, and horizontal items are best in medium windows.

Horizontal items are centered in the nav bar with outer margins.

_footer: The navigation bar is divided into equal-width segments with padding from the window edge_
_altText: The nav bar in a medium window with padding on each side._

### Icons

Navigation rail items must use icons that symbolize the content of their page. Browse [popular icon](https://fonts.google.com/icons).

Use a filled icon for the active destination and outlined icons for inactive destinations. If an icon doesn’t have a filled version, apply **semibold** weight to the icon instead.

_footer: Use filled icons when the navigation item is active_
_altText: An active nav item with a filled icon compared to inactive items with outlined icons._

_footer: If a filled version of an icon is unavailable, the icon’s weight must increase_
_altText: An active nav item with a semibold icon compared to inactive items with outlined icons._

Active and inactive icons must have a minimum 3:1 contrast ratio with the container.

_footer: Don’t use multiple or low-contrast colors in a navigation bar, as they make it harder for people to distinguish the active item and navigate to other destinations_
_altText: 4 nav items that are each different colors with low contrast with the background._

### Active indicator

The active indicator shows which page from the nav bar is currently being displayed.

_footer: Use the active indicator only for the active destination_
_altText: The current page in a nav bar has an active indicator._

_footer: Don’t use the active indicator for more than one destination at a time_
_altText: All items in a nav bar have active indicators._

### Label text

The label text should be a short, meaningful description of each navigation destination and another way for people to understand an icon’s meaning.

All navigation items require a label text. It should be 1-2 words.

_footer: Label text must be brief and clear_
_altText: A nav bar on a music app with clearly labelled destinations: home, browse, radio, library._

_footer: Use brief text labels to identify the purpose of a destination_
_altText: A nav bar with 1-word labels for each page._

_footer: Don’t wrap or truncate text as it can make the label hard to understand_
_altText: A nav bar with “Music catalog” for a label. The label is truncated._

_footer: Don’t shrink longer text to fit on a single line_
_altText: A nav bar with “Music catalog” for a label. The label is a smaller size to make the text fit._

### Badges (optional)

Navigation bars can display badges in the upper right corners of the destination icon.

Badges can contain dynamic information, such as the number of new messages.

_footer: Use a small badge to indicate an update, and a large badge to show the amount of updates_
_altText: A nav bar with a destination called “Go” with a small badge and one called “Saved” with a large badge saying “3.”_

_footer: Badges overlap the icon in both vertical and horizontal navigation items_
_altText: Horizontal nav items with the badges in the same place of the icon as vertical nav items._

## Placement

The floating action button (FAB) is placed above the navigation bar. Nav bars are always placed at the bottom of the window.

_footer: The FAB should be right-aligned above the navigation bar_

_footer: Don’t cover the navigation bar with a FAB_
_altText: A mobile page with a FAB overlapping a nav bar._

Navigation bars can be temporarily covered by dialogs, bottom sheets, navigation drawers, the on-screen keyboard, or other elements needed to complete a flow. They should not be permanently obstructed on any screen.

_footer: The search feature of the screen triggers the on-screen keyboard, temporarily covering the bottom navigation bar until the search flow is completed_
_altText: The navigation bar being covered by a bottom sheet when users take an action on screen._

## Adaptive design

Adaptive design allows an interface to respond or change based on context, such as the user, device, and usage. More on [adaptive design](/m3/pages/layout-overview/adaptive-design)

### Resizing

Only use navigation bars for compact and medium breakpoints. 

**Compact**: For narrow windows, use a navigation bar or modal navigation rail.

**Medium**: Use a navigation bar or navigation rail. Decide based on whether horizontal or vertical space is more important.

**Expanded and extra-large**: Use a navigation rail instead. Decide based on available window space and the number of navigation destinations.

_footer: Navigation bars are best suited for compact and medium breakpoints_
_altText: A music app with a nav bar adapting to larger screens, where it changes to horizontal items, and then into a nav rail._

The navigation bar container spans 100% of the window width.

_footer: Navigation bars use 100% of the screen width_
_altText: Navigation bar spanning the full width of a compact window._

The navigation bar is used on smaller devices. It’s not intended for desktop.

_footer: Don’t use navigation bars for desktop layouts. Instead, use a navigation rail or tabs._
_altText: Navigation bar spanning the full width of an expanded window size._

### Presentation

In medium breakpoints, use horizontal nav items to better use available space.

Horizontal nav items should remain centered with the same padding at each breakpoint.

_footer: A navigation bar in horizontal orientation keeps the same spacing between destinations_
_altText: Horizontal nav items have the same width in medium and expanded windows. Only the padding changes._

## Behavior

### Navigation

When selecting a navigation bar item not currently selected, the product navigates to that destination’s screen using a [top level](/m3/pages/motion-transitions/transition-patterns#f852afd2-396f-49fd-a265-5f6d96680e16) transition pattern. It can either remember where you left off, or reset to the default view.

- **Preserve state**: If someone has interacted with this destination, it returns to their scroll position, current tab, and in-line search status.
- **Reset state**: Any prior user interactions are reset, including scroll position, tab selection, and in-line search.

Choose the behavior that best suits the product and user needs. For example, an app that requires frequent switching between sections should preserve each section’s state.

_footer: After selecting an item on the bottom navigation bar, the app navigates to that destination’s screen_

Re-selecting the currently active destination should reset the scroll position to the top of the page.

**Don't swipe between destinations**
Swiping across the screen does not navigate between destinations, and is not supported by the navigation bar. Swipe behavior should be reserved for related items, such as cards in a carousel, or actions such as archiving a list item.

_footer: Selecting the already selected navigation item scrolls to the top of the screen_
_altText: Selecting the currently active nav item scrolls the page content back to the top._

### Scrolling

Upon scroll, the navigation bar can appear or disappear. 

Don’t hide the navigation bar on scroll when a [screen reader](https://m3.material.io/foundations/overview/assistive-technology#ec6f3e84-a51c-4dc0-a353-6844f5bde698) is active.

_footer: Scrolling downward can hide the navigation bar; scrolling upward reveals it_
_altText: When scrolling on the page, the nav bar scrolls the opposite direction off screen._

### Selection

The icon becomes filled and the active indicator expands from the center of the icon when switching between destinations.

The active indicator animation should only apply on one axis to better represent a flat, shared plane.

_footer: An active indicator appears when the item is selected._
_altText: The active indicator expands from the target when a destination is selected_

When a destination is tapped, the destination screens use a [top level](/m3/pages/motion-transitions/transition-patterns#f852afd2-396f-49fd-a265-5f6d96680e16) transition pattern. In addition, the icon becomes filled and the active indicator expands from the center of the icon.

_footer: Tapping a destination uses a top level transition pattern_
_altText: Selecting the home item changes the entire page contents._

starNote:This is a rapidly changing space. Guidelines are primarily intended for designers at this time. Find what’s implemented in code in the [design kit](https://www.figma.com/community/file/1035203688168086460).

Extended reality (XR) interfaces have special design requirements, like showing apps in 3D space. Material has an XR-specific navigation bar with custom specs and guidance. See [XR developer documentation](http://developer.android.com/design/ui/xr/guides/foundations) for more details.

## Anatomy

_footer: - Container - Icon - Active indicator - Small badge (optional) - Large badge (optional) - Large badge label (optional) - Label text_
_altText: Diagram of navigation bar orbiter identifying 7 internal elements of the component._

## Color & elevation

On XR, color is used to highlight elevated UI elements and orbiters. With [spatial elevation](https://developer.android.com/design/ui/xr/guides/spatial-ui#spatial-elevation), the navigation bar displays above the spatial panel, on the Z-axis. Color communicates elevation on UI elements and orbiters. Elevated nav bars can use any of these color options:

_footer: - Surface container - Surface container high - Surface container highest - Tertiary container_
_altText: 4 versions of elevation color strategy._

## Measurements

_footer: Navigation bar orbiter padding and measurements_
_altText: Measurements and padding for navigation bar orbiter._

## Usage

In full space, a navigation bar can appear in an orbiter for a more immersive experience. Currently, spatial capabilities, such as orbiters, are only available in full space. In home space, use a regular navigation bar on the same plane as the body content to mimic a 2D experience.

_footer: Navigation bar behavior and placement changing when going from a 2D to a 3D experience_
_altText: Interface showcasing navigation bar behavior and placement when transitioning from a 2D to 3D experience._

## Behavior

### Global context

When placed in global context, the navigation bar orbiter is centered at the bottom of the app it controls. It stays anchored to the app during layout or content changes. This ensures navigation elements are easy to find and use.

_footer: A navigation bar orbiter centered and anchored to the bottom of the app_
_altText: A navigation bar orbiter placed in global context._

### Local context

When placed in local context, the navigation bar orbiter is centered at the bottom of the spatial panel it controls. It repositions in response to layout or content changes.

_footer: Use caution before placing a navigation bar in local context. If it contains navigation elements that affect the overall app, a navigation bar orbiter should be placed in global context._
_altText: A navigation bar orbiter placed in local context._

## Placement

### Navigation context

The position of the navigation bar orbiter should communicate its navigational context:

- Use **offset positioning** for global actions that affect the overall app experience
- Use **inset positioning** for local actions that are specific to a spatial panel

A navigation bar orbiter can either overlap or be positioned adjacent to spatial panels with a 20dp margin for visual separation.

_footer: Position the navigation bar orbiter to reflect context: offset for global actions, inset for spatial panel-specific actions_
_altText: Navigation bar orbiter offset and inset positioning._

### Inset positioning

Don’t obstruct content. To ensure a balanced and uncluttered layout, a navigation bar orbiter should overlap spatial panels by 12dp and no more than half their height.

_footer: Avoid overlapping an inset a navigation bar orbiter by more than half its height_
_altText: Navigation bar orbiter inset positioning beyond the 12dp recommendation._

### Horizontal alignment

The navigation bar orbiter placement shouldn't exceed the width of adjacent spatial panels.

_footer: The navigation bar orbiter shouldn’t exceed the width of the spatial panel_
_altText: Nav bar orbiter placement that exceeds the width of its spatial panel._

### Spatial panel alignment

A navigation bar orbiter should always be placed at the bottom of a spatial panel and within the immediate field of view (FOV). Follow common usability practices to make the experience easy to use and consistent across platforms.

Avoid placing the navigation bar orbiter at the top of a spatial panel, as this area is typically reserved for app bar orbiters or other critical UI elements.

_footer: Don't position a navigation bar orbiter at the top of a spatial panel. Position it at the bottom in the field of view to maintain usability and minimize interaction effort._
_altText: Nav bar orbiter incorrectly placed above a spatial panel._

## Accessibility considerations

[XR accessibility](https://developer.android.com/design/ui/xr/guides/get-started#make-app) guidelines are still evolving. XR navigation bars should follow applicable Material [nav bar accessibility standards](/m3/pages/navigation-bar/accessibility).

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using the assistive technology:

- Move between navigation destinations
- Select a particular navigation destination from a set
- Get appropriate feedback based on input type

## Interaction & style

**Touch**

- When a navigation item is tapped, the active indicator appears in place, providing feedback that it’s selected
- A touch ripple passes through the indicator
- The icon switches from outlined to filled
- The icon changes color

_footer: Touch: Tap_
_altText: On a navigation bar, when the Home and Explore icons are tapped, an active indicator is displayed as interaction feedback._

**Cursor**

- When hovered, the active indicator appears in a reduced state providing a visual cue that the destination is interactive
- When clicked (in both active and inactive states), a ripple passes through the indicator
- The icon switches from outlined to filled
- The icon changes color, becoming darker

_footer: Cursor: Hover, Click_
_altText: On a navigation bar, the hover and click interactions on the Home and Explore icons have different interaction feedback._

### Text scaling and truncation

When someone sets their device to show a larger text size, the navigation bar should grow vertically to accommodate larger labels while retaining the default padding. It’s okay for scaled text to wrap in navigation items.

To remain accessible, ensure the full label is always visible on-screen at up to 2x text sizing. Beyond this size, text can truncate.

_footer: Text scaled to 1.5 size_
_altText: Nav bar with text scaled to 1.5x size. Some labels are on two lines, others are on one line._

_footer: Text scaled to 2x size_
_altText: Nav bar with text scaled to 2x size. Some labels wrap to two lines._

## Initial focus

Initial focus lands directly on the first navigation item, since that is the first interactive element of the component.

_footer: Focus lands on first navigation item_
_altText: Focus order and keyboard navigation of a nav bar._

_footer: The navigation item is selected with Space/Enter_
_altText: Activating a nav item with space on a keyboard._

## Visual indicators

Use a filled icon with a bold label for selected destinations. For unselected destinations use an outlined icon with a medium label.

If an icon doesn’t have a filled style, use a thicker or heavier version of the icon instead.

_footer: Use a filled icon for the selected navigation destination to differentiate from the other destinations_
_altText: A nav bar with a filled icon for the selected nav item._

_footer: Don’t use outlined icons on selected nav items_
_altText: A nav bar with an outlined icon for the selected nav item._

_footer: When selected, the icon fills, darkens, and is backed by an active indicator shape_
_altText: 2 nav items, one selected, one unselected._

## Keyboard navigation
Keys | Actions |
Tab | Move between navigation items |
Space / Enter | Selects the focused navigation item |

## Labeling elements

The accessibility label for a navigation item is typically the same as the destination name.

_footer: A navigation bar’s accessibility label can incorporate its adjacent UI text_
_altText: Accessibility label and role defined for a Home icon on a navigation bar._

When the visible UI text is ambiguous, accessibility labels need to be more descriptive. For example, a navigation destination visibly labeled **Library**would benefit from additional information in its accessibility label to clarify the destination’s intent.

Note: On Android Views (MDC-Android), a more descriptive accessibility label is not available and the role is not announced.

_footer: While the visible label text reads **Library**, the accessibility label for this destination clarifies its function: **Music library**_
_altText: Accessibility labels of a navigation bar._

---

<!-- Source: m3.material.io · components_navigation-rail · updated 2026-07-24T07:30:37.949Z · CC-BY 4.0 (Google) -->

## Navigation rail



<!-- section: Overview -->

- Use navigation rails in medium, expanded, large, or extra-large window sizes
- Can contain 3-7 destinations plus an optional FAB
- Always put the rail in the same place, even on different screens of an app

_footer: Collapsed and expanded navigation rails can transition between each other on any device, including:   1. Large or medium window size classes like tablets 2. Compact window size classes like phones in portrait orientation_
_altText: Navigation rail with 4 destinations, 1 active, and FAB._

## Availability & resources

## M3 Expressive update

**May 2025**

A **collapsed** and **expanded** navigation rail have been introduced to replace the baseline nav rail. The expanded nav rail is meant to replace the navigation drawer. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
The baseline **navigation rail** is no longer recommended

-
Added two wider navigation rails:

**Collapsed:** replaces baseline nav rail

-
**Expanded**: replaces navigation drawer

Configurations:

-
Expanded rail modality:

Non-modal

-
Modal

-
Expanded behavior:

Transition to collapsed navigation rail

-
Hide when collapsed

-
Color:

Active label on vertical items changed from **on surface variant** to **secondary**

_footer: The collapsed and expanded navigation rails match visually and can transition into each other_
_altText: A collapsed and expanded navigation rail._

## Differences from M2

- Behavior: Predictive back interaction
- Color: New color mappings and compatibility with dynamic color
- States: The active destination can be indicated with a pill shape in a contrasting color

_footer: M2: The navigation rail uses icon color, weight, and fill to communicate which destination is active_
_altText: M2 navigation rail with 1 colored and filled icon showing the active state and 3 inactive icons._

_footer: M3: The navigation rail uses a pill-shaped active indicator to communicate which destination is active_
_altText: M3 navigation rail with 1 icon surrounded by a pill shape in contrasting color to show the active state._

<!-- section: Specs -->

## Variants

_footer: - Collapsed navigation rail  - Expanded navigation rail_
_altText: 2 variants of navigation rails._

### Baseline variants

The baseline navigation rail is no longer recommended, and should be replaced by the collapsed navigation rail. [View baseline tokens](/m3/pages/navigation-rail/specs#d4d97764-20ec-496f-a6f3-0d423940ec5a)

_footer: - The baseline navigation rail is no longer recommended_
_altText: Baseline navigation rail._

Variant
 |
M3
 |
M3 Expressive
 |

Collapsed navigation rail

 |
--
 |
Available
 |

Expanded navigation rail 

 |
--
 |
Available
 |

Navigation rail (baseline)

 |
Available
 |
Not recommended.

Use **collapsed navigation rail**.

 |

## Configurations

_footer: - Expanded layout: standard - Expanded layout: modal_
_altText: Standard and modal layouts of navigation rail._

Category
 |
Configuration
 |
M3
 |
      M3 Expressive
 |

Expanded layout
 |
Standard (default)
 |
Available as navigation drawer

 |
Available
 |

Modal
 |
Available as navigation drawer

 |
Available
 |

Expanded behavior
 |
Hide when collapsed
 |
--
 |
Available
 |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: Collapsed and expanded navigation rail elements:  - Container - Menu (optional) - FAB or Extended FAB (optional) - Icon - Active indicator - Label text - Large badge (optional) - Large badge label (optional) - Small badge (optional)_
_altText: 9 elements of collapsed and expanded navigation rails._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Navigation rail color roles used for light and dark schemes:  - Surface container (optional)  - On secondary container  - Secondary container  - Secondary (vertical), On secondary container (horizontal)  - On surface variant  - On surface variant  - Error  - On error  - Error_
_altText: Color roles of 9 elements of collapsed and expanded navigation rails in light and dark color schemes._

## States

States are visual representations used to communicate the status of a component or an interactive element.

The navigation item’s target area always spans the full width of the nav rail, even if the item container hugs its contents.

_altText: 4 states of collapsed navigation rails._

_footer: - Enabled - Hovered - Focused - Pressed_
_altText: 4 states of expanded navigation rails._

## Measurements

_footer: Navigation rail padding and size measurements_
_altText: Padding and measurements for expanded and collapsed navigation rails._

## Common layouts

_altText: 4 common layouts of collapsed navigation rail._

_footer: - Three navigation items  - Three navigation items with a menu - Three navigation items with a FAB - Three navigation items with a menu and FAB_
_altText: 4 common layouts of expanded navigation rail._

## Baseline navigation rail

_footer: - Container - Menu icon (optional) - Icon - Active indicator - Label text - Large badge label (optional) - Large badge (optional) - Badge (optional)_
_altText: 8 elements of baseline navigation rail._

### Tokens & specs

### Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Navigation rail color roles used for light and dark themes:  - On secondary container - Secondary container - On surface - On surface variant - On surface variant - Error - On error - Error_
_altText: 8 color roles of baseline navigation rail._

### States

States are visual representations used to communicate the status of a component or interactive element.

_footer: Navigation rail states:  - Enabled (on active destination) - Hovered (on active destination) - Focused (on active destination) - Pressed (on active destination) - Enabled (on inactive destination) - Hovered (on inactive destination) - Focused (on inactive destination) - Pressed (on inactive destination)_
_altText: 8 states of baseline navigation rail._

### Measurements

_footer: Navigation rail size measurements_
_altText: Baseline nav rail size measurements._

_footer: Navigation rail padding and margin measurements_
_altText: Baseline nav rail padding and margin measurements._

### Configurations

Common arrangements of elements within a navigation rail.

_footer: - With a menu - With a FAB - With menu and FAB, without labels - All destinations with text labels - With menu, FAB, and label text for all destinations_
_altText: 5 configurations of the baseline navigation rail._

<!-- section: Guidelines -->

_footer: Use the menu icon to transition between collapsed and expanded navigation rails_
_altText: Colorful, purple navigation rail shown collapsed and expanded._

## Usage

The navigation rail can display navigation items, a menu, and a floating action button (FAB) in a vertical orientation.

There are two variants of navigation rails, **collapsed** and **expanded**, which can easily transform into each other when the menu button is selected.

### Collapsed

The **collapsed** nav rail runs along the leading edge of the window, and should contain 3–7 navigation items. It should not be hidden.

It can be used in medium to extra large breakpoints, such as tablets and desktop. In  medium windows with few destinations, consider using a navigation bar instead. Compact windows should always use a navigation bar.

_footer: A navigation rail should be the only visible navigation element_
_altText: Collapsed navigation rail with “timer” icon on FAB._

### Expanded

The **expanded** navigation rail can be standard or modal, and should always open from a menu icon. An expanded rail can reveal secondary destinations not visible when collapsed.

The **standard** configuration is placed beside body content. It’s best for larger windows with lots of available space.

The **modal** configuration overlaps the body content, and should be opened from a menu icon. Use the modal configuration for:

- Information dense layouts where space is limited
- Products with many navigation items

_footer: A navigation rail can be expanded by default on larger screen sizes, or can be expanded over content on smaller screen sizes_
_altText: Expanded navigation rail shown expanded by default and expanded over screen content._

In immersive experiences, the expanded navigation rail can be hidden entirely, appearing only when the menu icon is selected.

The collapsed navigation rail should not be hidden.

_footer: The expanded navigation rail can also be hidden, appearing only when the menu icon is selected_
_altText: Navigation rail and hidden navigation rail with menu icon button for expansion._

## Anatomy

_footer: - Container - Menu (optional) - Floating action button (FAB) (optional) - Icon - active - Label text - active - Active indicator - Icon - inactive - Large badge (optional) - Large badge label - Small badge - Label text - inactive_
_altText: 10 elements of expanded and collapsed navigation rails._

### Container

The navigation rail should be placed on the leading edge of the window. This is the left side for left-to-right languages, and the right side for right-to-left languages.

The container fill can be turned off so the nav rail appears directly on the surface. When doing this, make sure all items have a minimum of 3:1 color contrast.

_footer: The navigation rail should be placed on the leading edge of the window_
_altText: Right-to-left navigation rail in Hebrew, and left-to-right navigation rail in English._

The navigation rail should always run vertically along the side of a layout. Don’t make it horizontal.

Use a navigation bar for horizontal navigation.

_footer: Don’t use the navigation rail horizontally. Use a navigation bar instead._
_altText: Horizontal navigation rail on timer screen._

Navigation rail items can be aligned as a group to the top or center of a layout. On tablets, use center alignment to make it easier to reach items.

The menu icon and FAB should always be top-aligned.

_footer: Top and center aligned rail destination placement_
_altText: Navigation rails with different alignments._

### Menu (optional)

The menu button can transition between the **collapsed**and **expanded** navigation rails.

Once expanded, the rail can reveal secondary destinations.

When the navigation rail is expanded, the menu icon should change to represent that it can be collapsed.

_footer: A navigation rail can expand to reveal more destinations_
_altText: Expanded and collapsed navigation rails controlled by a menu icon button._

### Floating action button (FAB) (optional)

The container of the navigation rail is ideal for anchoring the FAB to the top of a screen, placing the app’s key action above navigation destinations.

When nested within another component, such as the navigation rail, the FAB's resting elevation should be [level 0](/m3/pages/elevation/applying-elevation).

_footer: A top-aligned FAB in the navigation rail_
_altText: Navigation rail with a FAB button at the top of the screen._

_footer: Avoid placing the FAB below navigation items_
_altText: Navigation rail with a FAB button at the bottom of the screen._

The top of the rail can also be used for a logo, however avoid using logos that could be mistaken as buttons.

Don’t use a logo as a menu button to expand the navigation rail.

_footer: Use caution when placing logos in the rail where they might be confused with an action or destination_
_altText: Navigation rail with Material design logo at the top of the screen._

### Active indicator

The active indicator shows which page is being displayed.

_footer: Use the active indicator only for the current open page_
_altText: Navigation rail with active indicators present for the current screen._

_footer: Don’t use the active indicator for more than one navigation item at a time_
_altText: Navigation rail with active indicators present for all navigation items._

The active indicator hugs the label text in the expanded nav rail. To achieve a similar style to the baseline navigation drawer, consider modifying the active indicator to fill the container.

The target area should always span the full width.

_footer: The active indicator hugs contents in the expanded nav rail_
_altText: Navigation rail with active indicator that hugs the text and icon._

_footer: Override the indicator to fill the container to more closely resemble the baseline navigation drawer_
_altText: Navigation rail with active indicator that is larger than the content within it._

### Icons

Navigation rail items must use icons that symbolize the content of their page. Browse popular icons on [Google Fonts](http://fonts.google.com/icons).

_footer: Icons should symbolize the content of the page they open_
_altText: Navigation rail with icons that fit the destinations, like a timer icon and label leading to a timer feature._

When a destination is selected, the icon fills and changes color. An active indicator appears behind the icon.

_footer: Selected navigation items have an active indicator, a filled icon, and a more prominent color_
_altText: Icons with and without an active indicator._

### Label text

The label text should be a short, meaningful description of each navigation destination and another way for users to understand an icon’s meaning.

All navigation items require a one word label text.

_footer: Write clear and concise labels that describe the destination page_
_altText: Navigation rail with clear text labels._

Avoid wrapping long labels when possible. If necessary, create a line break between words, or hyphenate longer words.

_footer: Break up longer phrases into two text lines if necessary_
_altText: Navigation rail with lengthy text labels._

Labels should be short enough to not be truncated. Don’t shrink the type scale to fit longer text labels.

_footer: Don’t truncate or display an ellipsis in place of label text_
_altText: Navigation rail with truncated text label with ellipses._

_footer: Don’t reduce the type size to fit more characters into a destination label_
_altText: Navigation rail with small text label._

### Badges

Navigation rail icons can include badges to communicate dynamic information about the  destination, such as counts or status.

In compact nav rails, the badge is placed in the upper right corner of the icon. In expanded nav rails, the badge should be placed next to the label text.

_footer: 1. Small badge on a rail destination  2. Large badge with a number 3. Large badge with a maximum character count_
_altText: Navigation rail with badges on each icon._

### Divider (optional)

A vertical divider can help separate the rail from app content. The divider should be positioned on the edge of the rail container that’s adjacent to the app’s content area.

_footer: A divider can make the navigation rail container distinct from other on-screen content_
_altText: Navigation rail with divider separating it from screen content._

## Placement

In adaptive layouts, the navigation rail should be placed outside any panes, always along the leading edge of the window. Don’t place it within body content.

When the navigation rail is hidden, the body content can fill in the remaining space as long as the menu icon is still accessible.

Tabs can be used alongside a navigation rail to create an extra layer of visible navigation.

_footer: Expanded navigation rails can open from menu buttons on mobile_
_altText: Navigation rail collapsed next to screen content, and expanded overlaying screen content with secondary destinations._

## Adaptive design

For more, see [adaptive design](/m3/pages/layout-overview/adaptive-design/).

### Resizing

When moving from a large screen to a small screen, a navigation rail can transform into a navigation bar, providing the same quick access in a configuration that’s easier to use on smaller displays. Never use the navigation rail and navigation bar simultaneously. 

Only use navigation rails for medium breakpoints and larger. Don’t use a navigation bar. If there are more than five destinations, consider using a modal expanded nav rail instead.

**Compact:** Don’t use a standard navigation rail for compact layouts due to space constraints. Use a navigation bar instead.

**Medium:** Use a navigation rail, especially if prioritizing persistent vertical navigation over maximizing vertical content space.

**Expanded to extra-large:** Use a navigation rail, not a navigation bar. Consider available horizontal space and the number of destinations when choosing between standard and modal.

_footer: On smaller devices, use a navigation bar. On larger displays, use a navigation rail._
_altText: Navigation bar on a phone screen and navigation rail on a tablet screen._

### Presentation

When the navigation rail transitions from collapsed to expanded, the contents of the page should automatically adjust to fit.

The contents of the navigation rail also expand to fill the space. For example, the FAB should transition into an extended FAB. 

Extra destinations can be shown in an expanded nav rail.

_footer: Use a standard expanded rail when there are secondary destinations or actions that have lower priority than the main navigation items_
_altText: Extra destinations in an expanded navigation rail._

## Behavior

### Scrolling

Destinations in the navigation rail should remain visible and fixed when scrolling vertically.

_footer: Rail destinations remain fixed while on-screen content scrolls vertically_
_altText: Screen content scrolls while rails stay fixed._

If a layout scrolls horizontally, the rail can scroll off-screen or remain fixed. To distinguish that content is scrolling underneath the rail, use a divider or add elevation to the rail.

_footer: A divider and color fill change create visual distinction between the rail and horizontally scrolling content_
_altText: A nav rail with a divider between it and the page’s content._

_footer: Elevating the rail to level 1 creates visual distinction between the rail and horizontally scrolling content_
_altText: A nav rail with slight elevation._

### Selection

When a destination is tapped, the destination screen uses a [top level](/m3/pages/motion-transitions/transition-patterns#f852afd2-396f-49fd-a265-5f6d96680e16) transition pattern. In addition, the icon becomes filled and the active indicator expands from the center of the icon.

_footer: Tapping a destination uses a top level transition pattern_
_altText: Selection transition between one navigation item and another._

### Back

On Android, a gesture called predictive back allows people to swipe left or right on the screen to go back or dismiss modal components.

- Previous screen is revealed in a preview to signal the destination
- Predictive back only applies to the **modal expanded** navigation rail.

A list of compatible components is available on the [gestures page](/m3/pages/gestures/).

_footer: The nav rail pops off the edge of the window during the predictive back gesture_
_altText: Modal expanded navigation rail with Android predictive back feature._

starNote:This is a rapidly changing space. Guidelines are primarily intended for designers at this time. Find what’s implemented in code in the [design kit](https://www.figma.com/design/cVjQvQ0moD8wkPWH2rn2c6/XR?node-id=294149-10229&t=AFAz42CCMXa5470T-4).

Extended reality (XR) interfaces have special design requirements, like showing apps in 3D space. Material has XR-specific navigation rails with custom specs and guidance. See [XR developer documentation](http://developer.android.com/design/ui/xr/guides/foundations) for more details.

## Variants

There are two variants of navigation rail orbiters: the contained FAB and spatialized FAB navigation rails.

_footer: - Contained FAB rail - Spatialized FAB rail_
_altText: Navigation bar orbiters with a contained FAB and a spatialized FAB._

## Anatomy

_footer: - Container - Active indicator - Large badge (optional) - Badge (optional) - Large badge label (optional) - Label text - Icon - Embedded or spatialized FAB (optional) - Menu icon (optional)_
_altText: Diagram of navigation rail orbiter identifying 9 internal elements of the component._

## Color & elevation

On XR, color is used to highlight elevated UI elements and orbiters. With [spatial elevation](https://developer.android.com/design/ui/xr/guides/spatial-ui#spatial-elevation), the navigation bar displays above the spatial panel, on the Z-axis. Color communicates elevation on UI elements and orbiters. Elevated nav rails can use any of these color options:

_footer: - Surface container with tertiary FAB - Surface container high with tertiary fixed dim FAB - Surface container highest with tertiary fixed dim FAB - Tertiary container with primary FAB_
_altText: 4 versions of elevation color strategy._

## Measurements

_footer: Navigation rail orbiter padding and measurements with contained FAB_
_altText: Measurements and padding for navigation rail orbiter with contained FAB._

_footer: Navigation rail orbiter padding and measurements with spatialized FAB_
_altText: Measurements and padding for navigation rail orbiter with spatialized FAB._

## Usage

In full space, a navigation rail can appear in an orbiter for a more immersive experience. Currently, spatial capabilities, such as orbiters, are only available in full space. In home space, use a regular navigation rail on the same plane as the body content to mimic a 2D experience.

_footer: Navigation rail orbiter behavior and placement changing when going from a 2D to a 3D experience_
_altText: Interface showcasing navigation rail behavior and placement when transitioning from a 2D to 3D experience._

## Behavior

### Global context

Intended for global navigation, a nav rail orbiter should be centered along the left or right edge of the app it controls. It stays anchored to the app during layout or content changes to ensure controls are easy to find.

_footer: A navigation rail orbiter should be placed in global context, centered and anchored to the left or right of the app_
_altText: A navigation rail orbiter placed in global context._

### Local context

Don’t place a navigation rail orbiter in local context or [between spatial panels](/m3/pages/navigation-rail/xr#519a112b-51d6-4200-96a9-54af92fb787d). Local placement can make controls hard to find. Nav rails are designed for app-level navigation, so should only use the global context.

_footer: Avoid placing a navigation rail orbiter in local context. It can be hard to find if placed between two spatial panels._
_altText: A navigation rail orbiter placed in local context._

## Placement

### Navigation context

The position of the navigation rail orbiter should communicate its navigational context:

- Use **offset positioning** for global actions that affect the overall app experience
- Use **inset positioning** for local actions that are specific to a spatial panel

A navigation rail orbiter can either overlap or be positioned adjacent to spatial panels with a 20dp margin for visual separation.

_footer: Position the navigation rail orbiter to reflect context: offset for global actions, inset for spatial panel-specific actions_
_altText: Navigation rail orbiter offset and inset positioning._

### Inset positioning

Don’t obstruct content. To ensure a balanced and uncluttered layout, a navigation rail orbiter should overlap spatial panels by 12dp and no more than half their width.

_footer: Avoid overlapping an inset navigation rail orbiter by more than half its width_
_altText: Nav rail orbiter overlapping content by more than half its width._

### Vertical alignment

A navigation rail orbiter can be aligned to the top, middle, or center of spatialized panels, providing different levels of visual prominence and accessibility.

Align the navigation rail orbiter based on the specific design and user experience goals for the application.

_footer: Align the navigation rail orbiter at the top, middle, or center of spatialized panels_
_altText: Nav rail orbiter positioning moving from the top, to middle, to center of spatialized panels._

The navigation rail orbiter placement shouldn't exceed the height of adjacent spatial panels.

_footer: The navigation rail orbiter shouldn’t exceed the height of the spatial panel_
_altText: A nav rail orbiter positioning above its spatial panel._

### Spatial panel alignment

Avoid placing a navigation rail orbiter between spatial panels. This negatively affects the interface structure.

For layouts that span more than two spatial panels, consider using a navigation bar orbiter.

_footer: Don't place a navigation rail orbiter between spatial panels_
_altText: A nav rail orbiter incorrectly positioned between spatial panels._

## Spatialized FAB

There are two variants of navigation rail orbiters with different FAB treatments:

-
**Contained FAB rail:** A contained FAB within the rail. This offers a compact and familiar layout.

-
**Spatialized FAB rail:** The FAB becomes an orbiter of it’s own and is placed outside the navigation rail orbiter. Use this for higher emphasis and a distinct spatial effect.

Use the spatialized FAB rail to emphasize key actions and leverage XR hierarchy. Use the contained FAB rail to be more subtle, and align the experience with the baseline navigation bar.

_footer: Choose between a navigation rail orbiter with a contained FAB or a spatialized FAB_
_altText: Interface showing the difference between a navigation rail orbiter with a contained FAB and spatialized FAB._

To maintain visual association, place the spatialized FAB in close proximity to the navigation rail orbiter. Material recommends a 20dp margin.

The spatialized FAB can be placed above or below the navigation rail orbiter.

_footer: Position the spatialized FAB close to the navigation rail orbiter_
_altText: Spatialized FAB positioned close to the navigation rail orbiter._

While the spatialized FAB and navigation rail orbiter are typically positioned together, their placement is adaptable.

_footer: Use caution when positioning spatialized FABs. Keep them within the height of adjacent spatial panels_
_altText: Spatialized FAB positioned with excessive spacing between itself and the navigation rail orbiter._

## Accessibility considerations

[XR accessibility](https://developer.android.com/design/ui/xr/guides/get-started#make-app) guidelines are still evolving. XR navigation rails should follow applicable Material [nav rail accessibility standards](/m3/pages/navigation-rail/accessibility).

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using the assistive technology:

- Navigate between navigation destinations
- Select a particular navigation destination from a set
- Get appropriate feedback based on input type

## Interaction & style

When a navigation item is tapped, the active indicator appears, providing the following feedback to the user that it is selected:

- A ripple passes through the indicator
- The icon switches from outlined to filled
- The icon and text change color

When hovered, the hover state appears, providing a visual cue that the destination is interactive.

_footer: Touch: Tap_
_altText: Colorful, purple navigation rail shown collapsed and expanded._

_footer: Cursor: Hover, Click_
_altText: Tap indicator on a collapsed nav rail._

The target area for expanded navigation rails spans the full width of the container, even though the active indicator visually hugs the content.

_footer: Touch: Tap_
_altText: Touch indicator on a nav rail._

Use a filled icon for the active destination and outlined icons for inactive destinations.

Active and inactive icon colors need sufficient contrast against the container.

_footer: Use the default color scheme to ensure proper contrast and emphasis on the active destination_
_altText: Navigation rail with filled element._

_footer: Don’t use more than two colors for destinations or low-contrast colors in the navigation rail. This will make distinguishing active items difficult._
_altText: Nav rail with multiple navigation destinations and multi-colored contrast._

If an icon doesn’t have a filled style, use the semibold icon weight instead.

_footer: An icon with no filled option should use the semibold weight when active_
_altText: Icon button with semibold weight, without filled options._

### Text scaling and truncation

When someone sets their device to show a larger text size, the navigation rail items should grow vertically to accommodate larger labels while retaining the default padding. It’s okay for scaled text to wrap in navigation items.

To remain accessible, ensure the full label is always visible on-screen at up to 2x text sizing. Beyond this size, text can truncate.

_footer: Text scaled to 1.5 size_
_altText: Nav rail with text scaled to 1.5x size. All labels are on one line._

_footer: Text scaled to 2x size_
_altText: Nav rail with text scaled to 2x size. Some labels wrap to two lines._

### Initial focus

Initial focus lands directly on the first interactive item, whether it’s the menu, the FAB, or the first navigation item.

From the FAB or menu, **Tab** brings the person to the navigation items. **Tab** or **Arrows** then navigate between items.

_footer: Use arrows to move between navigation items_
_altText: Arrows help people move between pages._

_footer: Use space/enter to activate the focused navigation item_
_altText: Space/enter help people choose a navigation destination._

### Visual indicators

Icons give the dominant cue of the navigation state. Use a filled icon for the selected destination to contrast with outlined icons for the non-selected destinations.

_footer: Use a filled icon variant on the selected navigation item to differentiate from inactive navigation items_
_altText: Nav bar with an active, filled icon button._

_footer: Avoid using the same unfilled icon style for both selected and unselected items because it lacks important visual feedback cue_
_altText: Selected navigation item without filled icon style._

## Keyboard navigation
Keys | Actions |
Tab / Arrows | Navigate between interactive elements |
Space / Enter
 | Selects an interactive element |

## Labeling elements

The accessibility label for a navigation item is typically the same as the adjacent text label.

When the visible UI text is ambiguous, accessibility labels need to be more descriptive. For example, a navigation item visibly labeled **Recent** would benefit from additional information in its accessibility label to clarify the destination's intent.

Note: On Android Views (MDC-Android), a more descriptive accessibility label is not available and the role is not announced.

_footer: While the visible label text reads **Recent**, the accessibility label for this switch clarifies its function: **Recent images**_
_altText: “Maps” is both the icon label text and the accessibility label._

---

<!-- Source: m3.material.io · components_navigation-drawer · updated 2026-07-30T05:22:52.002Z · CC-BY 4.0 (Google) -->

## Navigation drawer



<!-- section: Overview -->

starNote:The navigation drawer is no longer recommended in the Material 3 Expressive update. For those who have updated, use an [expanded navigation rail](/m3/pages/navigation-rail/overview/), which has mostly the same functionality of the navigation drawer and adapts better across breakpoints.

-
Use standard navigation drawers in expanded, large, and extra-large breakpoints

-
Use modal navigation drawers in compact and medium breakpoints

-
Can be open or closed by default

-
Two variants: standard and modal

-
Put the most frequent destinations at the top and group related destinations together

_footer: - Standard navigation drawer - Modal navigation drawer_
_altText: 2 variants of navigation drawers: standard and modal._

## Availability & resources

## M3 Expressive update

**May 2025**

The navigation drawer is no longer recommended. Use the expanded navigation rail instead. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color

-
Variants: Distinguishes two separate variants of navigation drawer: Standard and modal

-
Shape: Rounded corners at the ending edge of the drawer

-
States: Updated color and shape for indicating selected state

_footer: M2: Navigation drawer had square corners and a rectangular shape indicating the active destination_
_altText: M2 navigation drawer with 4 destinations in a mail app. The active destination “Inbox” is rectangular._

_footer: M3: Navigation drawer has rounded corners, new color mappings, and an updated style for indicating the active destination_
_altText: M3 navigation drawer with 4 destinations in a mail app. The active destination “Inbox” has rounded corners._

<!-- section: Specs -->

starNote:The navigation drawer is no longer recommended in the Material 3 Expressive update. For those who have updated, use an [expanded navigation rail](/m3/pages/navigation-rail/overview/), which has mostly the same functionality of the navigation drawer and adapts better across breakpoints.

_footer: - Container  - Headline  - Label text  - Active indicator  - Badge label text  - Scrim  - Icon_
_altText: Navigation drawer diagram numbering 7 elements_

## Tokens & specs

The navigation drawer has one token set. [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Navigation drawer color roles used for light and dark schemes:  - Surface container low - On surface variant - On secondary container - On secondary container - Secondary container - On secondary container - On surface variant - On surface variant - Scrim_
_altText: Navigation drawer diagram numbering 9 color roles._

For divider color roles, go to [divider specs](/m3/pages/divider/specs).

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: Navigation drawer states:   - Enabled - Hovered - Focused - Pressed_
_altText: 4 navigation drawers illustrating enabled, hovered, focused, and pressed states._

[State specs are in the tokens module above](/m3/pages/navigation-drawer/specs#6207b00f-a259-41d2-8146-b6efc6380976)

## Measurements

### Standard navigation drawer

_footer: Element size measurements_
_altText: Standard navigation drawer with measurements shown for various elements._

_footer: Padding and margins_
_altText: Standard navigation drawer with measurements shown for padding and margins._

Attribute | Value |
Container height
 | 100% |
Container width
 | 360dp |
Container shape
 | 0,16,16,0dp corner radii |
Icon size
 | 24dp |
Active indicator height
 | 56dp |
Active indicator shape
 | 28dp |
Active indicator width
 | 336dp |
Horizontal label alignment
 | Start-aligned |
Left padding
 | 28dp |
Right padding
 | 28dp |
Active indicator padding
 | 12dp |
Padding between elements
 | 0dp |

### Modal navigation drawer

_footer: Element size measurements_
_altText: Modal navigation drawer with measurements shown for various elements._

_footer: Padding and margins_
_altText: Modal navigation drawer with measurements shown for padding and margins._

Attribute | Value |
Container height
 | 100% |
Container width
 | 360dp |
Icon size
 | 24dp |
Active indicator height
 | 56dp |
Active indicator shape
 | 28dp |
Active indicator width
 | 336dp |
Horizontal label alignment
 | Start-aligned |
Left padding
 | 28dp |
Right padding
 | 28dp |
Active indicator padding
 | 12dp |
Padding between elements
 | 0dp |

<!-- section: Guidelines -->

starNote:The navigation drawer is no longer recommended in the Material 3 Expressive update. For those who have updated, use an [expanded navigation rail](/m3/pages/navigation-rail/overview/), which has mostly the same functionality of the navigation drawer and adapts better across breakpoints.

_altText: Navigation drawer with 4 primary destinations_

## Usage

Navigation drawers provide access to destinations and app functionality, such as switching accounts. They can either be permanently on-screen or opened and closed by a navigation menu icon. One navigation destination is always active.

Navigation drawers are recommended for:

- Apps with 5 or more top-level destinations
- Apps with 2 or more levels of navigation hierarchy
- Quick navigation between unrelated destinations
- Replacing the navigation rail or navigation bar on large screens

_footer: Use a navigation drawer for 5 or more primary destinations, or more than 1 level of navigation hierarchy_
_altText: Navigation drawer with multiple destinations in a mail app._

Avoid using a navigation drawer with other primary navigation components, such as a navigation bar.

Instead, choose a single navigation component based on product requirements and breakpoints:

-
Navigation bars for compact breakpoints

-
Navigation rails for medium and expanded breakpoints 

-
Standard navigation drawers for expanded, large and extra-large breakpoints

_footer: Avoid using two navigation components on the same screen_
_altText: Standard navigation drawer and navigation bar used together._

There are two variants of navigation drawers:

-
Standard navigation drawer

-
Modal navigation drawer

_footer: Standard navigation drawer_
_altText: Standard navigation drawer with destinations in mail app._

_footer: Modal navigation drawer_
_altText: Modal navigation drawer with destinations and scrim._

### Standard navigation drawer

Standard navigation drawers provide access to drawer destinations and app content for layouts in expanded, large, and extra-large breakpoints. 

Standard drawers can be permanently visible (best for frequently switching destinations) or opened and closed by tapping a menu icon (best for focusing more on screen content).

In medium and compact breakpoints, use modal drawers instead.

_footer: Standard navigation drawer providing access to drawer destinations next to app content_
_altText: Standard navigation drawer in a mail app with active destination “Inbox” next to app content._

### Modal navigation drawer

Modal navigation drawers use a scrim to block interaction with the rest of an app’s content, and don’t affect the screen’s layout grid.

Modal navigation drawers can be used in any breakpoint, but are primarily used in compact and medium sizes where space is limited or prioritized for app content.

They can be swapped with standard drawers on expanded, large, and extra-large breakpoints.

_footer: Modal navigation drawer using a scrim to block interaction with the rest of an app’s content_
_altText: Modal navigation drawer with 1 active destination and scrim._

Modal navigation drawers are always opened by an action outside of the drawer, such as clicking a navigation menu icon in a navigation rail.

Modal drawers can be dismissed by:

- Selecting a drawer item
- Tapping the scrim
- Swiping toward the drawer’s anchoring edge (for example, swiping right-to-left for a left-aligned navigation drawer)

_footer: A modal drawer opened by an action such as clicking a navigation menu icon (1)_
_altText: Diagram noting a navigation menu icon in a navigation rail._

Modal drawers can be dismissed by tapping the scrim or swiping the drawer toward its anchoring screen edge.

_footer: 1. Dismiss by tapping the scrim 2. Dismiss by swiping the drawer_
_altText: 2 modal navigations illustrating tapping the scrim or swiping to dismiss a modal drawer_

## Anatomy

Navigation drawers are essentially a list contained within a side sheet. They can also include headers, subheads, and dividers to organize longer lists.

_footer: Navigation drawers can include headers, subheads, and dividers to organize longer lists  - Active Indicator - Icon - Label - Badge label - Sheet - Divider - Section label (optional) - Scrim_
_altText: Navigation drawer diagram numbering 8 elements._

### Sheet

A sheet holds all navigation drawer elements. Side sheets are used as the container for standard and modal navigation drawers.

Navigation drawers that open from the side are always placed on the start edge of the screen, on the left for left-to-right (LTR) languages, and on the right for right-to-left (RTL) languages.

_footer: A navigation drawer opens from the left side of the screen for left-to-right languages_
_altText: Modal navigation drawer opening from left side of screen._

### Divider (optional)

Dividers can be used to separate groups of destinations within the navigation drawer.

_footer: Use full-width dividers (1) to separate groups of destinations_
_altText: Navigation drawer using horizontal dividers to separate a group of destinations_

_footer: Don’t use dividers to separate individual destinations_
_altText: Navigation drawer using horizontal dividers to separate individual destinations_

### Active indicator

The active indicator is a background shape communicating which destination of the navigation drawer is currently being displayed.

_footer: The active indicator (1) is a background shape communicating which destination of the navigation drawer is currently being displayed_
_altText: Navigation drawer diagram numbering 1 element._

### Label text and icons

Destinations in a navigation drawer take the form of actionable list items. Each item describes its destination using label text and an optional icon.

_footer: Actionable list items in a navigation drawer describe each destination using (1) an optional icon and (2) required label text_
_altText: Navigation drawer diagram numbering 2 elements._

Label text should be clear and short enough that it isn’t cut off by the sheet.

_footer: Navigation drawers can use text labels without icons_
_altText: Navigation drawer using only label text for 4 destinations. Label text “Inbox” in active destination._

_footer: Keep text labels concise, but truncate them if they extend beyond the container width_
_altText: Navigation drawer with 1 truncated text label._

_footer: Don’t wrap label text_
_altText: Navigation drawer with 1 text label with wrapped label text._

_footer: Don’t shrink text size in order to fit a text label on a single line_
_altText: Navigation drawer with 1 text label featuring smaller text._

Icons can supplement labels as indicators of a destination. When used, they should always be placed before text. Other app components and content should reference these icons.

_footer: Use recognizable icons when conventions exist_
_altText: Navigation drawer with active destination “Inbox” featuring recognizable icon._

_footer: Don’t apply icons to some destinations and not others. Icons should be used for all destinations, or none._
_altText: Navigation drawer with 4 destinations, 2 with text label and icon, 2 with only text label._

### Section label (optional)

Short subhead section labels can help group related destinations in the navigation drawer.

_footer: Related destinations can be grouped using short subhead section labels in the navigation drawer_
_altText: Navigation drawer showing subhead section labels._

### Scrim (modal only)

Modal navigation drawers use a scrim to block interaction with the rest of the app. The scrim is placed directly behind the drawer’s sheet and can be tapped or clicked to dismiss the drawer.

_footer: Scrim applied behind a modal navigation drawer_
_altText: Modal navigation drawer with scrim placed behind._

## Responsive layout

A product’s navigation component should change to suit the breakpoint and form factor of the screen.

Modal navigation drawers can be used at any breakpoint but are most common in compact and medium breakpoints.

Standard navigation drawers are best for expanded, large, and extra-large breakpoints. 

Use a transition when swapping components. For example, when switching from a portrait to landscape layout, the navigation rail should transform into a navigation drawer.

_footer: Standard navigation drawers change size to suit the device’s screen_
_altText: Navigation rail changing to navigation. drawer on a larger screen_

### Compact breakpoint

Use modal navigation drawers in compact breakpoints. Or swap the drawer for a navigation bar.

On web, when the screen size is smaller than 320 CSS pixels, swap the navigation drawer for a navigation bar to ensure accessibility.

_footer: Use a modal navigation drawer on mobile screens_
_altText: Modal navigation drawer with 1 active destination._

### Medium & expanded breakpoints

Use a modal navigation drawer alone or with a navigation rail on medium and expanded breakpoints.

When a navigation rail and modal navigation drawer are used together, the drawer can repeat destinations in the navigation rail as long as the drawer offers enough visual separation between levels of the navigation hierarchy.

A standard navigation drawer can be used in [single pane layouts](/m3/pages/understanding-layout/parts-of-layout) in expanded breakpoints.

_footer: Use a navigation rail on tablet screens, or also allow a drawer to open and close via a menu icon_
_altText: Navigation drawer on tablet with 1 active destination._

### Large and extra-large breakpoints

For web experiences on laptop and desktop devices, use either a standard navigation drawer, or a navigation rail that transitions into a modal navigation drawer.

_footer: Use a standard navigation drawer on large and desktop screens_
_altText: Navigation drawer showing 1 active destination._

## Behavior

### Scrolling

Navigation drawers can be vertically scrolled, independent of the rest of the screen’s content and UI. If the list of navigation destinations is longer than the height of the drawer, the drawer’s contents can be scrolled within the drawer.

_footer: When a navigation drawer is scrolled, the body content should remain stationary_
_altText: A navigation drawer on the left region of an email app is scrolled vertically without disturbing the rest of the content._

### Visibility

**Dismissible standard drawers** can be used for layouts that prioritize content (such as a photo gallery) or for apps where users are unlikely to switch destinations often. They should use a visible navigation menu icon to open and close the drawer.

_footer: A standard dismissible navigation drawer is opened and closed by tapping the navigation menu icon in the app bar (1), and remains open until the menu icon is tapped again (2)_
_altText: Side-by-side standard navigation drawer opened and then closed after tapping menu bar._

Permanently visible standard drawers allow quick navigation between unrelated destinations. They can’t be closed or dismissed by the user.

_footer: A permanently-visible standard navigation drawer on desktop_
_altText: Standard navigation drawer moving between destinations._

### Appearing

When a navigation drawer animates on screen, it uses an [enter and exit](/m3/pages/motion-transitions) transition pattern.

_footer: A navigation drawer animating on screen_
_altText: In an email app, navigation drawer opens on menu icon click, and closes on outside click._

<!-- section: Accessibility -->

starNote:The navigation drawer is no longer recommended in the Material 3 Expressive update. For those who have updated, use an [expanded navigation rail](/m3/pages/navigation-rail/overview/), which has mostly the same functionality of the navigation drawer and adapts better across window size classes.

## Use cases

Users should be able to: 

- Move between navigation destinations with assistive technology
- Select a particular navigation destination from a set
- Get appropriate feedback based on input type

## Interaction & style

**Touch**

- When a navigation item is tapped, the active indicator appears in place, providing feedback to the user that it is selected
- A touch ripple passes through the indicator
- The icon switches from outlined to filled
- The icon changes color, becoming darker

_footer: Touch: Tap_
_altText: Active indicator and other visual cues appear when nav drawers are tapped._

**Cursor**

- When hovered, the hover indicator appears providing a visual cue that the destination is interactive
- When clicked, a ripple passes through the indicator
- The icon switches from outlined to filled
- The icon changes color, becoming darker in light theme and lighter in dark theme, to increase the contrast

_footer: Cursor: Hover, Click_
_altText: When a cursor goes over a navigation drawer, a hover indicator appears. When tapped, the active indicator appears._

## Initial focus

Initial focus lands directly on the first navigation item, since that is the first interactive element of the component.

_footer: Focus lands on first navigation item_
_altText: 1. Tab lands on the first navigation item, Inbox. 2. Down arrow to get to the second navigation item, Outbox._

## Closing

The modal navigation drawer can be dismissed by selecting the scrim that covers the rest of the screen.

_footer: Select the scrim to close the navigation drawer_
_altText: A navigation drawer with a scrim covering the body content. A touch target is selecting the scrim._

## Visual indicators

Icons are the primary focus of the navigation and such give the dominant cue of its state. Use a filled icon for the selected destination to differentiate from the outlined icons of non-selected destinations.

_footer: The navigation item is selected via **Space**/**Enter**_
_altText: Space + enter is used to select the navigation item inbox._

_footer: Use a filled icon for the selected navigation destination to differentiate from the other destinations_
_altText: A navigation drawer with the home destination using a filled icon._

_footer: Avoid keeping the icon style for the selected navigation destination the same as unselected destination's icons. This removes an important visual indicator of which destination is active._
_altText: A navigation drawer with the home destination using an outlined icon._

_footer: When selected, the icon fills, darkens in light theme (or lightens in dark theme), and is backed by an active indicator shape_
_altText: A selected home icon using a filled icon and active indicator and a unselected home icon using an outlined icon._

## Keyboard navigation

**Keys** | **Actions** |
Tab | Focus lands on the first navigation destination  |
Space or Enter | Selects the focused navigation destination, and focus moves to the newly opened section (if applicable) |
Arrow | Navigate between destinations within the navigation drawer |

## Labeling elements

The accessibility label for a navigation item is typically the same as the destination name.

If the UI text is correctly linked, assistive tech (such as a screenreader) will read the UI text followed by the component’s role.

For Android Views (MDC-Android), a more descriptive accessibility label is not available to be set and the role is not announced.

_footer: A navigation drawer’s accessibility label can incorporate its adjacent UI text_
_altText: A navigation drawer item’s label text and accessibility label both read “photos.” The role is “tab.”_

When the visible UI text is ambiguous, accessibility labels need to be more descriptive. For example, a navigation destination visibly labeled **Recents** would benefit from additional information in its accessibility label to clarify the destination’s intent.

_footer: While the visible label text reads **Recents,** the accessibility label for this destination clarifies its function: **Recent images**_
_altText: A navigation drawer item’s label text is “recents”, the accessibility label is “recent images.” The role is “tab.”_

---

<!-- Source: m3.material.io · components_tabs · updated 2026-07-17T07:03:01.541Z · CC-BY 4.0 (Google) -->

## Tabs



<!-- section: Overview -->

-
Use tabs to group content into helpful categories

-
Two variants: primary and secondary

-
Tabs can horizontally scroll, so a UI can have as many tabs as needed

-
Place tabs next to each other as peers

_footer: - Primary tabs - Secondary tabs_
_altText: A bar of primary tabs with destinations labeled Flights, Trips, and Explore. And a bar of secondary tabs with destinations labeled Overview and Specifications_

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Layout: Icons and labels are now vertically centered within the container

_footer: Tab icons and labels are positioned in the vertical center of the container_
_altText: Bar of primary tabs with destinations labeled Flights, Trips, and Explore_

<!-- section: Specs -->

## Tokens and specs

Select a component variant below to see its elements, attributes, tokens, and their values.

## Primary tabs

_footer: - Container - Badge (optional) - Icon (optional) - Label - Divider - Active indicator_
_altText: 6 elements of primary tabs._

### Primary tabs color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Primary tab color roles used for light and dark schemes:  - Surface - Primary - Primary - On surface variant - On surface variant - Outline variant - Primary_
_altText: 7 color roles applied to primary tabs in light and dark themes._

### Primary tabs states

_footer: - Enabled (active destination) - Hover (active destination) - Focused (active destination) - Pressed (active destination) - Enabled (inactive destination) - Hover (inactive destination) - Focused (inactive destination) - Pressed (inactive destination)_
_altText: Diagram of all primary tab states in both light and dark mode_

## Secondary tabs

_footer: - Container - Badge (optional) - Label - Divider - Active indicator_
_altText: 5 elements of secondary tabs._

### Secondary tabs color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Secondary tab color roles used for light and dark schemes:  - Surface - On surface - On surface variant - Outline variant - Primary_
_altText: 5 color roles applied to secondary tabs in light and dark themes._

### Secondary tabs states

_footer: - Enabled (active destination) - Hover (active destination) - Focused (active destination) - Pressed  (active destination) - Enabled (inactive destination) - Hover (inactive destination) - Focused (inactive destination) - Pressed (inactive destination)_
_altText: Diagram of all secondary tab states in both light and dark mode_

## Measurements

_footer: Tabs are divided into equal sections, with labels and icons positioned vertically centered. The divider is included in the height, placed inside the container._
_altText: Diagram of measurements for four and two tabs per container, including icon and label placement._

_footer: Primary tab active indicators are inset 2dp on each side, have a fully rounded corner radius, and a minimum length of 24dp._
_altText: Diagram of Primary tab active indicator measurements._

Attribute
 | Value
 |
Container height (label text only) | 48dp |
Container height (icon and label text) | 64dp |
Icon size | 24dp |
Divider height | 1dp |
Primary active indicator height | 3dp |
Secondary active indicator height | 2dp |
Active indicator shape | 3, 3, 0, 0 |
Active indicator minimum length | 24dp |
Padding between inline icon and text | 8dp |
Padding between inline text and badge | 4dp |
Overlap of badge on stacked icon | 6dp |

<!-- section: Guidelines -->

## Usage

Tabs organize groups of related content that are at the same level of hierarchy.

_footer: Tab labels can include icons and text. Text labels should be short._
_altText: Mobile screen with 3 tabs: video, photos and audio. Each tab has an an icon and text._

There are two variants of tabs:

-
Primary tabs

-
Secondary tabs

Primary tabs are placed at the top of the content pane under an app bar. They display the main content destinations.

Secondary tabs are used within a content area to further separate related content and establish hierarchy.

_footer: - Primary tabs - Secondary tabs_
_altText: 3 primary tabs above 3 secondary tabs._

### Related content

Use tabs to group related content, not *sequential* content.

_footer: Utilize tabs to categorize related groups of content into clearly defined sets_
_altText: Scrolling up and down through content, then swiping left through tabs._

_footer: Don’t use tabs to move through sequential content that needs to be read in a particular order. Instead, create hierarchy within the content using techniques like typography style and open space._
_altText: Mobile screen with scrollable tabs of sequential content: Chapter 1, Chapter 2, Chapter 3 and Chapter 4._

## Anatomy

_footer: - Container - Icon (optional) - Badge (optional) - Label - Divider - Active indicator_
_altText: Six components of tabs._

### Container

The container holds multiple tabs. Its contents can be fixed or scrollable.

The container should always extend the full width of the window and be divided into equal sections, one for each tab.

The container is defined by a divider on the bottom edge to separate it from the content below. Content may scroll under the container.

_footer: The container is the area that contains the tabs directly under the title above_
_altText: Mobile screen with fixed tabs with a dotted border to illustrate the container area._

### Icon (optional)

Icons communicate the kind of content within a tab. Icons should be simple and recognizable.

_footer: Tabs can use a combination of labels and icons_
_altText: Mobile screen with tabs that use both icons and labels._

Icons alone aren’t as effective as text labels at communicating complex content.
Use caution when representing tab content with icons alone, as an icon’s meaning may not be clear.

_footer: Use icons that are globally recognized when using icons alone_
_altText: Mobile screen with tabs represented by icons  for “wishlist” and “location”._

_footer: Don’t use tabs with both icons and text labels on only some tabs, but not others_
_altText: Mobile screen where "purchases” tab has text only and “wishlist” tab has text and icon._

### Label

Text labels should clearly and succinctly describe the content within the tab.

Tab labels appear in a single row. Labels can use a second line if needed, with truncated text. Alternatively, scrollable tabs can allow room for longer titles.

_footer: Tab labels should be short and succinct. There should be a clear relationship to the title above._
_altText: Mobile screen with scrollable tabs in a single row._

When using scrollable tabs, the first visible tab should be offset by 52dp from the left side of the device for both web and mobile. The width of each tab is defined by the length of its text label.

Avoid using inconsistent padding on each tab.

_footer: Offset the first scrollable tab 52dp from the leading edge so it's clear that more content is available_
_altText: Screen with scrollable tabs offset from the leading edge by 52dp._

_footer: Don’t truncate labels unless required, as truncated text can impede comprehension_
_altText: Screen with scrollable tabs, 2 of which are truncated to “Australian” showing how truncation can confuse users._

### Badges (optional)

Badges can be used on primary or secondary tabs to show notifications or updates related to a specific tab. Limit badge content to four characters, including a "+".

Once the user views the relevant content in the tab, the badge value should update or the badge should disappear entirely.

Small and large badges can both be used with tabs. Read the [badge guidance](/m3/pages/badges/overview) for more details.

_footer: Badges are used to highlight notifications related to tab specific content_
_altText: Mobile screen with tabs that use both icons and labels._

### Active indicator

To differentiate an active tab from an inactive tab, apply an underline and color change to the active tab’s text and icon.

_footer: An underline and color change differentiate an active tab from the inactive ones_
_altText: Selecting a tab creates an underline below the  icon and text, both which have changed color to show the tab is active._

## Choosing the tab variant

Primary tabs should be used when just one set of tabs are needed.

Secondary tabs are necessary when a screen requires more than one level of tabs. These tabs use a simpler style of indicator, but their function is identical to primary tabs.

_footer: Tabs can be joined with components like app bars, embedded in a specific UI region, or nested within components like cards and sheets. Tabs control the UI region displayed below them._
_altText: Mobile screen with primary tabs near the top of the screen._

## Placement

Tabs are displayed in a single row, with each tab connected to the content it represents. As a set, all tabs are unified by a shared topic.

Secondary tabs should always be placed below primary tabs.

_footer: Secondary tabs are found within other content to assist users with greater detail_
_altText: Mobile screen with secondary tabs below the primary tabs._

## Responsive layout

For fixed tabs, the maximum width for each tab should be determined by the width of the widest tab. The group of tabs should use a fluid margin and align to the center or leading edge of the body region.

Avoid using more than four tabs at once. At five or more tabs, the container becomes cramped.

_footer: Tabs can grow in width in relation to the number of items contained within_
_altText: Four fixed tabs spaced to match one another._

## Behavior

### States

By default, tabs inherit enabled states with one active state.The inactive and active states of a tab can inherit a hover, focus, and pressed states.

_footer: Active, hover, focused, and pressed states_
_altText: Four states of a tab._

### Fixed tabs

Fixed tabs display all tabs in a set simultaneously. They are best for switching between related content quickly, such as between transportation methods in a map. To navigate between fixed tabs, tap an individual tab, or swipe left or right in the content area.

_footer: Fixed tabs allow users to see all possible kinds of content available_
_altText: Mobile screen with fixed tabs, text only._

#### Tap a tab

Navigate to a tab by tapping on it.

_footer: Tapping on a tab directly_
_altText: Tapping a tab selects it._

#### Swipe within the content area

To navigate between tabs, users can swipe left or right within the content area.

_footer: Users can swipe between fixed tabs to see related content quickly_
_altText: Swiping left or right on the content area moves the focus between fixed tabs._

Use caution when placing other swipeable content (such as interactive maps or list items) in the content area.

_footer: Use different gesture directions when using tabs_
_altText: Scrolling up and down through content, then swiping left through tabs._

_footer: Avoid placing swipeable items in the content area of a UI that has tabs, as the user may mistakenly swipe the wrong component_
_altText: Swiping to change tabs accidentally swipes to delete a list item in the UI instead._

### Scrollable tabs

When a set of tabs cannot fit on screen, use scrollable tabs. Scrollable tabs can use longer text labels and a larger number of tabs. They are best used for browsing on touch interfaces.

_footer: Padding should remain the same when using scrolllable tabs and long labels_
_altText: Scrolling left and right on scrollable tabs._

### Scrolling content

When a screen scrolls up and down through content, tabs can either be fixed to the top of the screen, or scroll off the screen. If they scroll off the screen, they will return when the user scrolls upward.

_footer: Tabs can be use to create elevation_
_altText: Scrolling through content with fixed tabs  at top of the screen._

_footer: Tabs can scroll offscreen on scroll, and reappear when the page is scrolled up_
_altText: When scrolling up through content, tabs scroll off screen, then reappear when scrolling back down._

_footer: Don’t scroll tabs behind an app bar. When tabs are attached to a component, they should appear and move as a single unit._
_altText: When scrolling up through content, tabs scroll behind the app bar then reappear when scrolling back down._

<!-- section: Accessibility -->

## Use cases

Users should be able to:

- Undertake actions or invoke navigation to a new destination with assistive tech
- Select an action or destination from an off screen tab with assistive tech
- Maintain access of primary actions when the content is in a scrolled state

## Interaction & style

**Touch**

- When a user taps on an icon button, a touch ripple appears, indicating interaction feedback
- The selected indicator becomes active and shifts into position once the touch has been engaged

_footer: Touch: Tap_
_altText: The ripple effect resulting from tapping on an action item._

**Scrollable**

- When a set of tabs cannot fit on screen, scrollable tabs are used. They are best used for browsing on touch interfaces.
- To navigate between scrollable tabs, users swipe the set left or right. Users can also use arrow/tab to navigate through.
- It's **not recommended** to loop a tab set where it scrolls infinitely. This can trap users who are navigating linearly with a screen reader.
- To select an individual tab, users tap or press space/enter.
- Horizontal scrolling tabs meet accessibility requirements because they need to increase in width to respond to label text without affecting the layout, and horizontal scrolling is necessary to view those labels.

_footer: Scrollable: Scrollable Tabs_
_altText: Swiping right and left scrolls through tabs when scrolling is enabled._

**Cursor**

- When hovered, the hover state appears, providing a visual cue that the icon button is interactive. When clicked (in both active and inactive states), a ripple appears and the indicator shifts into position, showing the user feedback.

_footer: Cursor: Hover, Click_
_altText: Hover state appears when hovering over tabs, clicking on them changes the state to active._

**Keyboard/Switch**

- When tabbed, a focus indicator appears, providing a visual cue to the user that the destination is now selected
- When the user engages with the selected tab via Space/Enter in active states, the user is taken to a new destination
- Within the tab menu, the user is able to arrow/tab through the menu items, Space/Enter to select an item, or tab to exit the active state

_footer: Keyboard/Switch: Tab, Space/Enter, Arrow_
_altText: Tabbing through navigation items. The focus indicator appears when an item is selected._

### Avoid applying density by default

Don't apply density to tabs by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

## Initial focus

On arrow/tab in a tab menu, the active indicator appears on the first interactive element, providing feedback to the user that it is selected. The user is then able to tab to additional interactive elements until all available items are complete within the tab menu.

_footer: Use Arrow/Tab to navigate through items_
_altText: Arrow or Tab being used to navigate through a tab menu._

_footer: Don't use Space/Enter for navigating tabs. Space/Enter is only used for completing actions._
_altText: Space or Enter being used to navigate through a tab menu._

## Keyboard navigation

Keys | Actions |
Arrow | Focus lands on the next available navigation destination |
Space / Enter | Activates the focused navigation destination |
Arrow | Allows navigation through menu items |

## Labeling elements

When the visible UI text is ambiguous, or there is no visible UI text, accessibility labels need to be more descriptive. For example, an icon button that visually represents a “video camera” requires additional information in its accessibility label to clarify the icon’s intent.

_footer: While the icon visually represents a “Video camera,” the accessibility label for this tab clarifies its function: “Video format media content”_
_altText: Small device screen  with the tab highlighted and the label and role illustrated._
