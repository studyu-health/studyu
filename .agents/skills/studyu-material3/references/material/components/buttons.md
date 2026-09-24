# Material 3 · Buttons

<!-- Source: m3.material.io · components_all-buttons · updated 2026-07-17T06:58:41.575Z · CC-BY 4.0 (Google) -->

## All buttons

> When choosing the right button for an action, consider the level of emphasis each button type provides



<!-- section: Tab 1 -->

##### There are 10 types of buttons in Material 3.

_footer: - Button - Toggle button - Icon button - Toggle icon button - Split button - Standard button group - Connected button group - Floating action button (FAB)  - Extended FAB - FAB menu_
_altText: 10 types of buttons._

## Choosing buttons

Level of emphasis
 |
Component
 |
Rationale
 |
Example actions
 |

High emphasis: For the primary, most important, or most common action on a screen
 |
[Extended FAB](/m3/pages/extended-fab/overview/), [FAB](/m3/pages/fab/overview/), and [FAB menu](/m3/pages/fab-menu/overview)

 |
The FAB and extended FAB are the largest and most visually prominent buttons. They’re designed for a page’s primary action. The extended FAB is best on large screens. The FAB menu provides multiple options.

 |
Create 
Compose
New thread
New file

 |

[Button (filled)](/m3/pages/common-buttons/guidelines#9ecffdb3-ef29-47e7-8d5d-f78b404fcafe)

 |
The filled button’s primary color palette makes it the most prominent button after the FAB. It’s used for final or unblocking actions in a flow.

 |
Save
Confirm
Done

 |

[Split button](/m3/pages/split-button/overview)

 |
The split button’s primary color palette and menu icon are best used for key actions with multiple options.

 |
Send
Add
Create

 |

[Button group](/m3/pages/button-groups/overview)

 |
The standard button group uses color, motion, and shape to capture attention. Use it to show multiple key actions.

 |
Back, Pause, Next

 |

Medium emphasis: For important actions that don’t distract users from the main task
 |
[Button (tonal)](/m3/pages/common-buttons/guidelines#07a1577b-aaf5-4824-a698-03526421058b)
 |
The tonal button has a secondary color palette, making it less visually prominent than a regular, filled button. It can be used for final or unblocking actions, or for supporting actions.

 |
Save
Confirm
Done

 |

[Button (elevated)](/m3/pages/common-buttons/guidelines#4e89da4d-a8fa-4e20-bb8d-b8a93eff3e3e)
 |
The elevated button has a secondary color palette and a shadow. Only use it when a button requires visual separation from a patterned background.

 |
Reply
View all
Add to cart
Take out of trash

 |

[Button (outlined)](/m3/pages/common-buttons/guidelines#3742b09f-c224-43e0-a83e-541bd29d0f05)

 |
Use an outlined button for actions that need attention but aren’t the primary action, such as “See all” or “Add to cart.” This is also the button to use for giving someone the opportunity to change their mind or escape a flow.
 |
Reply
View all
Add to cart
Take out of trash

 |

Low emphasis: For optional or supplementary actions with the least amount of prominence
 |  |
The connected button group shows multiple related options. Use it for changing the content visible on a page.

 |
Walk, Bike, Drive

 |

[Button  (text)](/m3/pages/common-buttons/guidelines#c9bcbc0b-ee05-45ad-8e80-e814ae919fbb)
 |
The text button has no outline or fill. It should be used for actions not essential to the user journey.

 |
Learn more
View all
Change account
Turn on

 |

[Icon button](/m3/pages/icon-buttons/overview)
 |
The most compact and subtle type of button, icon buttons are used for optional supplementary actions such as “Bookmark” or “Star.”

 |
Add to Favorites Print

 |

## Hierarchy

**One high emphasis button**

Each screen should contain a single prominent button for the primary action. This high-emphasis button commands the most attention. The arrangement of on-screen elements should clearly communicate that other buttons are less important.

**Other buttons**

A product can show more than one button at a time in a layout. Use different color styles to create visual hierarchy and indicate the importance of each button.

_footer: A button’s level of emphasis helps determine its appearance, typography, and placement_
_altText: 3 types of hierarchy: high emphasis, medium emphasis, and low emphasis._

## Placement

Use a combination of button styles on the same screen to focus attention on a primary action, while offering alternatives.

_footer: - A filled button for a high-emphasis action - A text button for a low-emphasis action - An extended FAB for the highest emphasis action_
_altText: Newsfeed screen with 3 different types of buttons following the emphasis hierarchy._

_footer: For multiple actions, choose a higher-emphasis button for the more important action, such as a filled button next to a text button_
_altText: Text button to the left of a filled button._

_footer: When using multiple buttons, you can place an outlined button (medium emphasis) next to a filled button (high emphasis)_
_altText: Outlined button to the left of a filled button._

_footer: When using multiple buttons, you can place a text button (low emphasis) next to an outlined button (medium emphasis)_
_altText: Text button to the left of an outlined button._

_footer: Use a filled button on its own for a single important action_
_altText: Single filled button at the bottom of a mobile screen._

_footer: Avoid placing a button below another button if there's space to place them side-by-side_
_altText: Filled button stacked above a text button._

---

<!-- Source: m3.material.io · components_buttons · updated 2026-07-24T06:19:49.216Z · CC-BY 4.0 (Google) -->

## Buttons



<!-- section: Overview -->

-
Two variants: default and toggle

-
Can contain an optional leading icon

-
Five color options: elevated, filled, tonal, outlined, and text

-
Five size recommendations: extra small, small, medium, large, and extra large

-
Two shape options: round and square

-
Keep labels concise and use sentence case

_footer: - Elevated button - Filled button - Filled tonal button - Outlined button - Text button_
_altText: 5 variants of buttons._

## Availability & resources

## M3 Expressive update

**May 2025**

Buttons now have a wider variety of shapes and sizes, toggle functionality, and can change shape when selected. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
Default and toggle (selection)

-
Color styles are now configurations (elevated, filled, tonal, outlined, text)

Shapes: 

-
Round and square

-
Shape morphs when pressed

-
Shape morphs when selected

Sizes:

-
Extra small

-
Small (existing, default)

-
Medium

-
Large

-
Extra large

New padding for **small** buttons:

-
16dp (recommended to match padding of new sizes)

-
24dp (no longer recommended)

_footer: - Five sizes - Toggle (selection) - Two shapes - Two small padding widths_
_altText: 4 button changes in the expressive update._

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color. Icons and labels now share the same color. Neutral text button is no longer recommended.

-
Icons: Standard size for leading and trailing icons is now 20dp

-
Shape: Fully-rounded corner radius and additional height options

_footer: M2: Buttons have a height of 36dp and slightly rounded corner radius_
_altText: Rectangular M2 buttons._

_footer: M3: Default buttons are taller at 40dp and have fully rounded corners_
_altText: Round-cornered M3 buttons._

<!-- section: Specs -->

## Variants

_footer: - Default button  - Toggle button_
_altText: Diagram comparing buttons with toggle buttons._

Variant
 |
M3
 |
M3 Expressive
 |

Default
 |
Available
 |
Available
 |

Toggle (selection)
 |
--
 |
Available
 |

## Configurations

_footer: - Size - Shape - Color - Small button padding_
_altText: Diagram showing configurations of buttons._

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Size
 |
Small (default)
 |
Available
 |
Available
 |

XS, M, L, XL
 |
--
 |
Available
 |

Shape
 |
Round (default)
 |
Available
 |
Available
 |

Square
 |
--
 |
Available
 |

Color
 |
Elevated, filled (default), tonal, outlined, text
 |
Available
 |
Available
 |

Small button padding
 |
24dp
 |
Available
 |
Not recommended.

Use 16dp
 |

16dp
 |
--
 |
Available
 |

## Tokens & specs

Use the table's menu to select a token set. Button token sets are separated into common tokens, color, and size. [View baseline tokens](/m3/pages/common-buttons/specs#c305d304-a6c0-466a-a48c-8d0718a29ae2)

## Anatomy

_footer: - Container - Label text - Icon (optional)_
_altText: Diagram labeling 3 parts of a button._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.

-
There are five built-in button color styles: elevated, filled, tonal, outlined, and text

-
The default and toggle buttons use different colors

-
Toggle buttons don’t use the text style

starNote:These color roles were chosen to create design coherence and familiarity. Other color roles can be used as long as the container and text have a 3:1 contrast ratio. For example, tertiary and on tertiary.

_footer: A. Elevated, B. Filled, C. Tonal, D. Outlined, E. Text  - Default - Toggle: unselected - Toggle: selected_
_altText: Diagram shows dark and light color schemes for buttons._

|
1. Default
 |
2. Toggle unselected
 |
3. Toggle selected
 |

Elevated container

Elevated icon & label
 |
Surface container low

Primary
 |
Surface container low

Primary
 |
Primary

On primary
 |

Filled container

Filled icon & label
 |
Primary
On primary
 |
Surface container

On surface variant
 |
Primary

On primary
 |

Tonal container

Tonal icon & label
 |
Secondary container

On secondary container
 |
Secondary container

On secondary container
 |
Secondary

On secondary
 |

Outlined container

Outlined icon & label
 |
Outline variant (outline)

On surface variant
 |
Outline variant (outline)

On surface variant
 |
Inverse surface

Inverse on surface
 |

Text icon & label
 |
Primary
 |
--
 |
--
 |

## States

States are visual representations used to communicate the status of a component or interactive element.

### Elevated button states

The elevated button style has an elevation of 1 by default and 0 when disabled.

#### Default

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Elevated button states._

#### Toggle

_footer: A. Unselected, B. Selected  - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Toggle elevated button states._

### Filled button states

#### Default

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Filled button states._

#### Toggle

_footer: A. Unselected, B. Selected  - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Toggle filled button states._

### Tonal button states

#### Default

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Tonal button states._

#### Toggle

_footer: A. Unselected, B. Selected  - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Toggle tonal button states._

### Outlined button states

The outlined button’s container fill is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed.

#### Default

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Outlined button states._

#### Toggle

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Outlined button states._

### Text button style states

The text button’s container is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed. There is no toggle text button.

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Default text button style states._

## Shape morph

### Pressed state

When pressed, buttons can morph to become more square. Both round and square buttons should have the same pressed shape.

The corner radius value differs for each button size. [See full button corner measurements](/m3/pages/common-buttons/specs#b1f39738-6f3a-409b-8f08-4cab6d78d756)

_footer: A. Round button, B. Square button  - Enabled - Hovered - Pressed_
_altText: Shape changes of a button._

### When selected

In addition to changing shape when pressed, toggle buttons also change the resting shape from round (unselected) to square (selected). 

If the resting unselected shape is square, the selected shape should be round.

_footer: A. Round button, B. Square button  - Enabled  - Hovered  - Pressed  - Selected_
_altText: Shape changes of a toggle button._

## Measurements

_footer: Padding and size measurements of each button size  - Extra small - Small - Medium - Large - Extra large_
_altText: Diagram of measurements of all button sizes._

### Target areas

Extra small and small icon buttons must have a target size of 48x48dp or larger to be accessible.

_footer: A. Extra small  B. Small  - Round button - Button with icon - Square button_
_altText: Diagram of small button target areas._

### Corner sizes

_altText: Diagram of corner radii of buttons._

| XS
 | S
 | M
 | L
 | XL
 |
A. Round button | Full | Full | Full | Full | Full |
B. Square button | 12dp | 12dp | 16dp | 28dp | 28dp |
C. Pressed state | 8dp | 8dp | 12dp | 16dp | 16dp |

## Baseline tokens

Use the table's menu to switch token sets. The baseline button token sets are organized by color.

<!-- section: Guidelines -->

_footer: Buttons and icon buttons come in many shapes, styles, and sizes_
_altText: Buttons in various shapes and sizes._

## Usage

Buttons communicate actions that people can take. They are typically placed throughout the UI, in places like:

-
Dialogs

-
Modal windows

-
Forms

-
Cards

-
Toolbars

They can also be placed within standard button groups.

_footer: Use visually-prominent filled buttons for the most important actions_
_altText: Video call app with prominent filled button to join and end a call._

Buttons are just one option for representing actions in a product and shouldn’t be overused. Too many buttons on a screen can disrupt the visual hierarchy.

Consider placing additional actions in a navigation rail, set of chips, text links, or icon buttons.

_footer: Use buttons for discrete actions_
_altText: 1 button placed on bottom right of screen._

_footer: Don’t clutter your UI with too many buttons. Consider presenting low-priority actions in overflow menus or as icon buttons._
_altText: 3 buttons side by side on bottom of screen._

_footer: A button container’s width is dynamically set to fit its label text_
_altText: Filled button on menu screen._

_footer: Button container width can be responsive, which allows it to stretch horizontally_
_altText: Filled button as wide as layout grid._

_footer: A button container’s width shouldn’t be narrower than its label text_
_altText: Filled button with label text overflowing the container._

_footer: A: Default button; B: Toggle (unselected); C: Toggle (selected) for five button styles, in order of emphasis:  - Elevated button - Filled button - Filled tonal button - Outlined button - Text button_
_altText: Diagram of button styles and toggle behaviors._

A button group is a collection of buttons that relate to each other and can respond to one another. Both buttons and icon buttons can be used inside a button group.

In some cases, there are primary and secondary actions within a button group. Buttons with primary actions should have a higher visual emphasis through size, color, or shape.

[More on button groups](/m3/pages/button-groups/overview)

_footer: Different sized buttons in a button group help emphasize the main action from secondary actions_
_altText: Audio app with play, next, and back buttons._

## Toggle buttons

Toggle buttons should be used for binary selections, such as **Save** or **Favorite**. When toggle buttons are pressed, they can change color, shape, and labels.

Toggle buttons should use an outlined icon when unselected, and a filled version of the icon when selected. If a filled version doesn’t exist, increase the weight instead.

By default, toggle buttons change from round to square when selected.

_footer: Use toggle buttons for binary actions_
_altText: Toggle “stop” button in timer app._

If the label changes on selected or unselected states, be mindful of the character count. Changing the label significantly is disruptive to the user and the page layout.

_footer: When using toggleable buttons, keep the label character count a similar length for both states_
_altText: Toggleable “start” and “reset” buttons._

_footer: The label length shouldn’t change dramatically to be longer or shorter_
_altText: Toggleable “start” and “reset back to beginning” buttons._

## Anatomy

_footer: - Label text - Container - Icon (optional)_
_altText: 3 parts of a button._

### Label text

Label text is the most important element of a button. It describes the action that will occur if someone taps a button. It should be very brief, ideally 1–3 words.

Use sentence case, which only capitalizes the first word and proper nouns. This allows the text to distinguish proper nouns, for example: **Book with Flights**, not **BOOK WITH FLIGHTS**.

Don’t truncate or wrap label text. It should always be fully visible on a single line.

_footer: Use sentence case for button label text, capitalizing the first word and proper nouns_
_altText: Button with label text “See all recipes.”_

_footer: Don’t wrap text. For maximum legibility, label text should remain on a single line._
_altText: Button with wrapped label._

Buttons with the **outlined** and **text** color style depend on the colors to be recognizable from other text and elements. Use caution when putting these buttons next to visually similar elements, such as chips or large text.

_footer: The outlined button style is very similar to chips. Consider using a filled or tonal button instead._
_altText: Chips next to an outlined button, highlighting their similarities._

### Container

Button containers hold the label text and optional icon. Buttons with the **text** color style have a visible container only when hovered, focused, or pressed.

Buttons with a round shape have containers with fully rounded corners.

_footer: Round buttons have containers with fully rounded corners_
_altText: Round button._

Buttons with a square shape have containers with more subtle rounding that changes based on button size.

_footer: Square buttons have square containers and change radius as the button size changes_
_altText: Square buttons with different radii._

_footer: A button’s width dynamically adjusts to the label text_
_altText: Button with the label text “Edit playlist” within the container._

_footer: Avoid setting a fixed width smaller than the label text_
_altText: Button with text larger than its container._

### Icon (optional)

Icons visually communicate the button’s action and help draw attention. They should be placed on the leading side of the button, before the label text.

_footer: Place the icon to the left of the label in buttons with text in left-to-right languages_
_altText: Filled button with the icon to the left of the label in a left-to-right language._

_footer: Place the icon to the right of the label in buttons with text in right-to-left languages_
_altText: Filled button with the icon to the right of the label in a right-to-left language._

_footer: Use icons that clearly communicate their meaning_
_altText: Button with shopping cart icon and text label “Add to cart”._

_footer: Don’t vertically align an icon and text in the center of a button_
_altText: Button with Plus icon vertically above the text label “Add to watch list”._

_footer: Don’t use two icons in the same button_
_altText: Button with two icons._

## Color styles

### Elevated style

The **elevated** button style is the same as the tonal button, but with a shadow. 

To avoid overusing shadows, use the elevated style only when absolutely necessary, such as when the button requires visual separation from a visually prominent background.

_footer: Elevated buttons provide separation from a visually prominent background_
_altText: Elevated button on a scrim background._

Buttons at higher elevations typically have more emphasis in a design, and should be used sparingly. For high emphasis, consider the filled style instead.

_footer: Higher elevation increases the emphasis of a button_
_altText: Elevated button in a shopping experience._

### Filled style

The **filled** button style has the most visual impact after the FAB, and should be used for important, final actions that complete a flow, like **Save**, **Join now**, or **Confirm**.

_footer: Filled buttons have high visual impact when used for important actions_
_altText: Filled button reading “Make payment.”_

Since they have such strong emphasis, the filled style should be used sparingly, ideally for only one action on a page.

In some cases, filled buttons can use tertiary colors.

_footer: Filled buttons can be responsive to the layout grid and help emphasize main actions_
_altText: Filled “pause” button in a music app._

### Tonal style

The **tonal** button style is useful in contexts where a lower-priority button requires slightly more emphasis than an outline would give, such as **Next** in an onboarding flow. Tonal buttons use the secondary color mapping.

_footer: The tonal style has less emphasis than filled or emphasis_
_altText: Shopping app with 2 tonal-style filled buttons._

### Outlined style

The **outlined** style is ideal for medium-emphasis buttons which contain actions that are important, but aren’t the primary action in a product.

Outlined buttons pair well with filled buttons to indicate alternative, secondary actions.

_footer: Outlined buttons contain less important supporting actions_
_altText: Outlined buttons for less important actions, including a back button and a button that reads “Next movie.”_

Outlined buttons display a stroke around the button container, and have no fill by default. 

They should be placed on simple backgrounds, not visually prominent backgrounds such as images or videos.

_footer: Outlined buttons display a stroke around the button container_
_altText: Outlined button for “add to cart” in shopping app._

_footer: Outlined buttons can be used on backgrounds with a color gradient_
_altText: Outlined button labeled Add to calendar on a pink/purple background._

_footer: Use caution when placing outlined buttons on top of images. Customizing the button to have a contrasting container fill can help ensure legibility of label text. Or, use a filled button instead._
_altText: 2 photos, each with an outlined button with a custom fill._

### Text style

The text button style should be used for the lowest priority actions, especially when presenting multiple options.

They should be placed on simple backgrounds, not visually prominent backgrounds such as images or videos. The container isn’t visible until someone interacts with the button.

Don’t underline the text button. Use hyperlinked body text instead to emphasize links. [More on hyperlinks](/m3/pages/typography/applying-type#24856f70-f759-45df-a06c-92018f286083)

_footer: Use text buttons for the lowest priority actions_
_altText: Example calendar screen with 2 text buttons and 1 split button._

Text buttons are often placed within components such as cards, dialogs, and snackbars. Since text buttons don’t have a visible container in their default state, they don’t distract from nearby content.

However, since there’s no container, the label text color must always be recognizable from non-button text and elements.

_footer: Text button in a snackbar_
_altText: Text button labeled “Retry” in a snackbar._

_footer: Text button against an image background_
_altText: Text button labeled “View album” on an album cover background._

In cards, text buttons help maintain an emphasis on card content.

_footer: Text button in a card_
_altText: Text button labeled “Learn more” in an information card about sourdough bread._

Dialogs use text buttons because the absence of a container helps unify the action with the dialog text.

Align text buttons to the trailing edge of dialogs, on the right for left-to-right languages and on the left for right-to-left languages.

_footer: Text buttons in a dialog_
_altText: Modal dialog with the title “Subscribe to our newsletter?” and trailing buttons “Cancel” and “Subscribe”._

## Adaptive design

### Resizing

When scaling layouts for large screen devices, buttons can adapt their visual presentation, size, alignment, and arrangement to fit different contexts and user needs.

Choose the best button position based on screen size.

_footer: Filled buttons are end-aligned below flight information in a compact window_
_altText: Flights app in compact screen with buttons below flight information._

_footer: Filled buttons are start-aligned beside flight information in a large window_
_altText: Flights app in large screen with buttons to the left of flight information._

The icon and label text in a button stay centered and grouped as the button's width changes.

_footer: Keep the icon and label text grouped and centered_
_altText: 2 buttons with horizontally centered text labels._

_footer: Don't ungroup the icon and label text or let them anchor to opposite sides of the button_
_altText: 1 button with centered text label, 1 button with icon and label aligned to opposite edges._

Buttons can be customized to change size and scaling behavior across different breakpoints. 

To avoid creating very long buttons in large windows, constrain button width or place buttons beside other elements.

_footer: Don’t allow the button to stretch in a way that creates long, flat buttons with very little content inside_
_altText: Button width is over-stretched with screen width._

### Presentation

The size and placement of buttons can change as parent containers, such as cards, adapt for larger screens. 

Keep items, including buttons, in the same order between large and small screens to provide a consistent experience for screen readers and keyboard navigation.

_footer: Buttons can move in the layout, but elements should remain in the same order_
_altText: 2 buttons scaling to accommodate different device sizes._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology: 

- Use a button to perform an action
- Navigate to and activate a button

## Interaction & style

### Color contrast

Enabled buttons need a 3:1 contrast ratio with the background to meet accessibility best practices. 

This is measured from the container for elevated, filled, and tonal button styles, and the label text for outlined and text button styles.

_footer: Higher contrast helps differentiate elements_
_altText: Diagram of color contrast ratios for buttons._

### 200% text size

Avoid excessive text wrapping or truncation by choosing concise strings. 

On Android, button labels should be kept concise enough to fit within two lines after the text size is increased to 200%. If a button label exceeds this limit and gets truncated, provide an alternative way to access the full content in a single tap.

_footer: Avoid excessive text wrapping or truncation by choosing concise strings_
_altText: 200% text size on a mobile screen. The overly long button text wraps to a second line: “Download playlist for offline access”._

### Rapid clicks

On the web, you can use a modified motion curve to avoid resonant effects from overlapping animations. This provides a smoother experience for interactions where you anticipate multiple clicks or taps in succession.

_footer: Use the modified motion curve if rapid click or pointer interactions are expected_
_altText: A media player where the “next track” button is clicked rapidly, and is transformed with a smooth motion effect._

## Keyboard navigation

Keys | Actions |
Tab | Navigate to a button |
Space or Enter | Activate a button |

## Labeling elements

The accessibility label for a button should match the visible label text on the button such as **Done**, **Send**, or **Reply**. 

It can contain extra contextual information if necessary.

_altText: Accessibility tags for a text-only button._

---

<!-- Source: m3.material.io · components_button-groups · updated 2026-07-27T13:52:43.683Z · CC-BY 4.0 (Google) -->

## Button groups



<!-- section: Overview -->

-
Two variants: **standard** and **connected**

-
Applies shape morph when pressed and selected

-
Connected button groups replace the segmented button

-
Works with all button sizes: XS, S, M, L, and XL

-
Support for single-select, multi-select, and selection-required

_footer: Button groups can contain buttons and icon buttons_
_altText: A standard button group and a segmented button group._

## Availability & resources

## M3 Expressive update

Button groups apply shape, motion, and width changes to buttons and icon buttons to make them more interactive. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

**May 2025**

New component added to catalog.

Variants and naming:

-
Added standard button group

-
Added connected button group

Use instead of segmented button, which is no longer recommended

Configurations:

-
Works with all button sizes: XS, S, M, L, and XL

-
Applies default shape to all buttons: round or square

_footer: Button groups are containers that hold buttons of many shapes and sizes_
_altText: Standard button group in 3 of 5 available sizes, and segmented button group with just icon buttons and just common buttons._

<!-- section: Specs -->

## Variants

_footer: - Standard button group - Connected button group_
_altText: Various colors and shapes of standard and connected button groups._

Variant
 |
M3  
 |
M3 Expressive
 |

Standard button group
 |
--
 |
Available
 |

Connected button group
 |
Available as segmented button

 |
Available
 |

## Configurations

_footer: Configurations for both variants of button groups:  - Extra small  - Small  - Medium  - Large  - Extra large  - Single-select and multi-select  - Round and square_
_altText: Five sizes of button groups and two shapes of button groups._

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Size
 |
XS, S, M, L, XL
 |
--
 |
Available
 |

Default shape
 |
Round, square
 |
--
 |
Available
 |

Selection
 |
Single-select, multi-select, selection-required
 |
Available as segmented button

 |
Available
 |

## Tokens & specs

Standard and connected button group tokens are organized by size. Select the variant and size from the token set menu. Go to the [button](/m3/pages/common-buttons/specs/) and [icon button](/m3/pages/icon-buttons/specs/) pages to view their tokens. [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

Button groups are invisible containers that add padding between buttons and modify button shape. They don’t contain any buttons by default.

_footer: - Container_
_altText: The container outlined on both variants of button groups._

### Common layouts

Mix and match buttons and icon buttons for different scenarios.

_footer: - Label buttons - Label buttons and icon buttons - Extra small icon buttons - Large icon buttons_
_altText: 4 common layouts of button groups._

### Color

Button groups have no color properties. They can use the default button or toggle button color styles, like filled, tonal, and outlined. Avoid using standard icon buttons or text buttons, as they have no container treatment.

_footer: - Filled  - Tonal  - Outlined  - Elevated_
_altText: The container outlined on both variants of button groups._

## Selection & activation

**Standard button groups** add interaction between adjacent buttons when a button is selected or activated.

This interaction changes the width, shape, and padding of the selected or activated button, which adjusts the width of buttons directly next to it.

_footer: A selected button changes shape, and briefly changes the width of itself and adjacent buttons_
_altText: A selected button in a standard group bounces against its adjacent button, changing their widths._

**Connected button groups** don’t add any interaction between buttons when selected or activated. 

They only affect the shape of the button being selected or activated.

_footer: A selected button changes shape without affecting adjacent buttons_
_altText: A selected button in a connected button group only changes its own shape._

## States

### Standard button group

When a button is pressed, standard button groups modify the width and shape of that button and adjacent buttons.

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: 5 states of a standard button group._

When a toggle button is selected in a standard button group, its shape should change between square and round. The color should change according to the [button specs](/m3/pages/common-buttons/specs).

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: 5 states of a standard button group with toggle buttons._

### Connected button group

Connected button groups have different shape changes than standard button groups. Selecting a button does not affect adjacent buttons.

_footer: Connected button group unselected states:  - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: 5 states of a segmented button group._

_footer: Connected button group selected states:  - Enabled - Hovered - Focused - Pressed_
_altText: 4 states of a segmented button group with toggle buttons._

## Measurements

### Standard button group

Standard groups apply padding between all buttons. The amount of padding changes based on button size to ensure a minimum accessible target size of 48dp. More details on padding: [Button specs](/m3/pages/common-buttons/specs), [icon button specs](/m3/pages/icon-buttons/specs)

_footer: Standard button group inner padding:  - XS: 18dp - S: 12dp - M: 8dp - L: 8dp - XL: 8dp_
_altText: Standard button group padding measurements._

### Connected button group

For all connected button groups, use 2dp padding. This provides visual consistency at scale.

_footer: Round connected button group inner padding is 2dp at every size. The outer shape is fully round, and the inner shape remains square with the following corner sizes:  - XS: 4dp - S: 8dp - M: 8dp - L: 16dp - XL: 20dp_
_altText: Connected button group padding and corner radius measurements._

_footer: Square connected button group inner padding is 2dp at every size. The outer shape has the following corner sizes:  - XS: 4dp - S: 8dp - M: 8dp - L: 16dp - XL: 20dp_
_altText: Connected button group padding and corner radius measurements for square buttons._

### Minimum widths

Extra small and small connected button groups have 48dp target areas and a minimum width of 48dp.

_footer: - Extra small - Small_
_altText: 48x48dp accessible target areas on the XS and S connected button groups._

## Density

Button groups adapt to density of the buttons inside. [More on density](/m3/pages/grids-spacing/density)

_footer: Button groups adapt to the height of the buttons inside, including when density is applied_
_altText: Connected button groups at 0, -1, -2, and -3 density._

<!-- section: Guidelines -->

_footer: Standard button groups add interaction between adjacent buttons_
_altText: A video call with a standard button group. Selecting the mic changes shape and color, and bounces against adjacent buttons._

## Usage

There are two variants of button groups: **standard** and **connected**. 

**Standard button groups** add interaction between adjacent buttons so they respond to each other. When a button in a standard group is selected:

-
The selected button changes shape and width

-
A selected toggle button also changes color

-
Adjacent buttons move and temporarily change width

_footer: Button groups add more expression to a product_
_altText: A welcome screen with a colorful standard button group. 2 pink icon buttons are narrow, and 1 purple button is labelled “Get started"._

Mix and match the different  button variants, widths, and colors to emphasize what’s important, and to visually group related buttons.

By default, all buttons in a standard group should be the same size (XS to XL) and shape (round or square).

-
Only use multiple sizes in a group for hero moments

-
Avoid mixing sizes frequently

-
Only use a different shape in a group when a button is selected, or to add meaning or contrast

_footer: Use the same shapes for buttons in a group, but change other properties like width and color_
_altText: A standard button group with 3 buttons of different colors but the same square shape._

_footer: Reserve shape differences in button groups for key interactions_
_altText: A standard button group with 3 buttons, including a round primary button. A square button is used to add items._

**Connected button groups** help people select options, switch views, or sort elements in a page. 

They behave similarly to standard groups, except they don’t affect adjacent buttons.

Connected groups should replace the baseline segmented button, which is no longer recommended.

_footer: Connected button groups can be used to toggle between similar actions_
_altText: Selecting a button in a connected button group labelled “My files,” “Shared,” and “Computers.”_

Use connected button groups when the button content is related, and buttons can be selected.

_footer: Closely related actions work well in a connected button group_
_altText: A shopping app with an option to choose the volume of an item using a connected button group._

Connected button groups should be used for single or multi-select patterns that use toggle buttons. 

Avoid using a connected group when none of the buttons can be toggled.

_footer: Use the connected button group with single or multi-select patterns_
_altText: 2 filters using connected button groups of 2 and 4 items. The group with 4 items has multiple buttons selected._

### Color

Avoid mixing color styles in connected button groups; it can make selection and emphasis unclear.

_footer: Don’t mix color styles in connected button groups_
_altText: Selecting a button in a connected button group labelled “My files,” “Shared,” and “Computers.”_

## Anatomy

_footer: - Container_
_altText: 1 element of a button group._

### Container

The standard button group container has padding between buttons so they can animate width and shape without disrupting the product layout. 

The standard button group hugs the width of the buttons inside.

_footer: Button groups can animate without affecting their surroundings_
_altText: The container hugs the buttons. Inner padding is highlighted._

The connected button group should span the width of the page or surface it’s placed on, increasing the button widths inside. 

In larger windows, consider adding a maximum width to the connected group to avoid it growing too wide.

_footer: Connected button groups increase the widths of each button inside and expand to their container width_
_altText: 2 connected button groups, with 2 and 4 buttons respectively, spanning the same width on a screen, with margins from the edge._

## Adaptive design

Adaptive design allows an interface to respond or change based on context, such as the user, device, and usage. [More on adaptive design](/m3/pages/layout-overview/adaptive-design/)

### Resizing

Button groups should move through layouts together in a single line. They shouldn’t wrap to a second line. Multiple button groups can be stacked to keep items close together. However, button groups don’t interact vertically.

Button groups and individual buttons can be set to **fixed** or **flexible** resizing:

-
**Fixed**: Manually define the button width (narrow to wide), size (XS to XL), or padding at each breakpoint.

-
**Flexible**: Automatically increase or decrease the width of buttons and the button group. Button groups grow until all flexible buttons are at their largest width.

If adjusting button width manually, avoid stretching icon buttons beyond the wide setting.

_footer: Buttons can have width, size, and padding manually adjusted to fit different breakpoints_
_altText: Two button groups, each with distinct width, size, and padding adjusted to fit two different window sizes._

In compact windows, consider using smaller, narrower buttons so all buttons in the button group can fit. In large and extra large windows, consider using larger, wider buttons to better fill in the available space.

Flexible buttons or button groups will automatically adjust width.

_footer: Set the size, shape, and padding to manually adjust the button group at different breakpoints_
_altText: Button group is adjusted to fill the window size._

When scaling to larger breakpoints, make sure that the visual hierarchy of each button is preserved using qualities like color and size. 

For example, the primary action should remain the largest, widest, or most visually prominent button at all breakpoints.

_footer: Maintain hierarchy across layouts and devices_
_altText: Narrow buttons in a group on a compact window become a mixture of wide and narrow buttons on a larger window._

### Presentation

Buttons at the trailing edge of the button group can be customized to collapse into an overflow menu at smaller breakpoints, and become visible again at larger sizes. Place the overflow menu at the trailing end of the group.

Buttons outside the group aren’t affected by button group behavior.

_footer: Buttons should become hidden in an overflow menu or visible again, depending on screen size. Buttons outside the button group, like the **end call** button, will not be affected._
_altText: Buttons collapse into an overflow menu when window size shrinks, and reappear when window size expands._

## Behavior

### Pressed

When a button is pressed, it changes width and shape.

In a standard button group, pressing a button also affects the width of adjacent buttons.

In a connected button group, only the shape of the pressed button changes.

_footer: Pressing buttons in a standard group changes the width of adjacent buttons_
_altText: In a calculator app, pressing numbers changes the width of adjacent numbers._

### Selected

A selected button should change shape from round to square, or square to round.

_footer: Selected buttons should change shape_
_altText: A video call with a standard button group. Selecting the mic changes shape and color, and bounces against adjacent buttons._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

- Navigate to and interact with each button in the group 
- Identify when buttons are selected

## Interaction & style

Each button in a group should have a minimum 48x48dp target. 

Extra small and small button groups have larger inner padding to ensure accessible targets. Avoid reducing the padding in these sizes.

_footer: - Extra small button group - Small button group_
_altText: Extra small and small button groups with 48x48dp target areas annotated over top. The area is larger than the buttons._

### Initial focus

The button group container is not a focusable element. Initial focus should land on the first button in the group and then move to each button.

_footer: Initial focus should land on the first button, not on the container_
_altText: Focus order lands on the first button, then the next buttons._

Use **Tab** to navigate through each item in the group, and **Space** or **Enter** to select buttons.

_footer: - Initial focus - Selected button_
_altText: Button group with annotations for navigation with Tab and selecting with Space or Enter._

## Keyboard navigation
Keys | Actions |
Tab | Navigates to the next button |
Space or Enter | Activates the focused button |

## Labeling elements

The button group container does not need to be labeled. Label each button according to the button and icon button accessibility guidance.

_footer: Label each button within the button group_
_altText: In a messaging products, an email icon is labelled “email” with the role “button”._

---

<!-- Source: m3.material.io · components_icon-buttons · updated 2026-07-17T07:05:22.141Z · CC-BY 4.0 (Google) -->

## Icon buttons



<!-- section: Overview -->

-
Icon buttons must use a system icon with a clear meaning

-
Two variants: default and toggle

-
Many configurations: Color, size, width, and shape

-
On web, display a tooltip describing the action while hovering

-
In toggle buttons, use the outlined style of an icon for the unselected state, and the filled style for the selected state

_footer: Standard, filled unselected, filled selected, filled tonal, and outlined icon buttons_
_altText: 5 kinds of outline buttons._

## Availability & resources

## M3 Expressive update

**May 2025**

Icon buttons now have a wider variety of shapes and sizes, changing shape when selected. When placed in button groups, icon buttons interact with each other when pressed. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
Default and toggle (selection)

-
Color styles are now configurations. (filled, tonal, outlined, standard)

Shapes:

-
Round and square options

-
Shape morphs when pressed

-
Shape morphs when selected

Sizes:

-
Extra small

-
Small (default)

-
Medium

-
Large

-
Extra large

Widths: 

-
Narrow

-
Default

-
Wide

_footer: - Five sizes - Two shapes - Three widths_
_altText: Icon buttons can vary in size, shape, and width._

## Differences from M2

-
**Color:** New color mappings and compatibility with dynamic color

-
**Variants and naming:**Icon buttons were called toggle buttons. There are now two variants of icon buttons: default and toggle.

_footer: - Default icon buttons - Toggle icon buttons_
_altText: Icon buttons were known as toggle buttons in M2._

<!-- section: Specs -->

## Variants

_footer: - Default icon button - Toggle icon button_
_altText: Side by side view of default and toggle icon buttons._

Variant
 |
 M3

 |
M3 Expressive

 |

Default

 |
Available

 |
Available

 |

Toggle (selection)

 |
Available

 |
Available

 |

## Configurations

_footer: - Five sizes - Two shapes - Four color styles - Three widths_
_altText: Side by side view of size, shape, color, and width variations._

Category
 |
Options

 |
M3

 |
M3 Expressive

 |

Size

 |
Small (default)

 |
Available

 |
Available

 |

XS, M, L, XL

 |
--

 |
Available
 |

Shape

 |
Round (default)

 |
Available

 |
Available

 |

Square

 |
--

 |
Available

 |

Color

 |
Filled (default), tonal, outlined, standard

 |
Available

 |
Available

 |

Width

 |
Default

 |
Available

 |
Available

 |

Narrow, wide

 |
--

 |
Available
 |

## Tokens & specs

Icon button token sets are organized by common tokens, color, and size. Select the token set from the table’s menu. [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: - Icon  - Container_
_altText: Diagram indicating anatomy of filled icon button._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value.

There are four built-in color styles: filled, tonal, outlined, and standard. Default and toggle buttons use different color roles per style.

starNote:These color roles were chosen to create design coherence and familiarity. Other color roles can be used as long as the container and text have a 3:1 contrast ratio. For example, tertiary and on tertiary.

_footer: A: Filled, B: Tonal, C: Outlined, D: Standard  - Default - Toggle, unselected - Toggle, selected_
_altText: Color roles of default and toggle buttons in 4 visual styles._

|
1. Default
 |
2. Toggle, unselected
 |
3. Toggle, selected
 |

Filled container

Filled icon
 |
Primary 

On primary
 |
Surface container

On surface variant
 |
Primary

On primary
 |

Tonal container

Tonal icon
 |
Secondary container

On secondary container
 |
Secondary container

On secondary container
 |
Secondary

On secondary
 |

Outlined container

Outlined icon
 |
Outline variant (outline)

On surface variant
 |
Outline variant (outline)

On surface variant
 |
Inverse surface

Inverse on surface
 |

Standard icon
 |
On surface variant
 |
On surface variant
 |
Primary
 |

## States

States are visual representations used to communicate the status of a component or interactive element. State layers slightly change button color. Disabled states have different base colors. [View tokens for details](/m3/pages/design-tokens/overview)

### Filled button states

#### Default

_footer: - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of filled icon button._

#### Toggle

_footer: A: Unselected. B: Selected  - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of filled toggle icon button._

### Tonal button states

#### Default

_footer: - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of tonal icon button._

#### Toggle

_footer: A: Unselected. B: Selected  - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of tonal toggle icon button._

### Outlined button states

#### Default

_footer: - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of outlined icon button._

#### Toggle

_footer: A: Unselected. B: Selected  - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of outlined toggle icon button._

### Standard icon button states

The standard icon button’s container is invisible at rest, but visible when the state layer is applied.

#### Default

_footer: - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of standard icon button._

#### Toggle

_footer: A: Unselected. B: Selected  - Enabled - Disabled (10% state layer) - Hovered (8% state layer) - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 5 states of standard toggle icon button._

## Shape morph

### Pressed state

While pressed, icon buttons can morph to become more square. 

Both round and square icon buttons should have the same pressed shape radius.

The corner radius value differs for each button size. [See full icon button corner measurements](/m3/pages/icon-buttons/specs#b3df1f02-d313-44e9-9542-37f7e0e24dc7)

_footer: A. Round, B. Square  - Enabled - Hovered - Pressed_
_altText: Shape changes for round and square icon buttons in 3 states._

### When selected

In addition to changing shape when pressed, toggle icon buttons also change the resting shape from round (unselected) to square (selected) by default.

If the resting shape is square, the selected shape should be round.

_footer: A. Round, B. Square  - Enabled - Hovered - Pressed - Selected_
_altText: Shape changes for round and square toggle icon buttons in 3 states._

## Measurements

_footer: A. Extra small  B. Small  C. Medium  D. Large  E. Extra large  - Icon size - Default width size - Narrow width size - Wide width size_
_altText: Diagram of 5 sizes of icon buttons in 4 widths._

### Target sizes

Extra small and small icon buttons must have a target size of 48x48dp or larger to be accessible.

_footer: A. Extra small icon button size  B. Small icon button size  - Narrow width - Default width - Wide width_
_altText: Diagram of target sizes._

### Button corner radius

_altText: Diagram of icon button corner radius._

| XS | S | M | L | XL |
A. Round button | Full | Full | Full | Full | Full |
B. Square button | 12dp | 12dp | 16dp | 28dp | 28dp |
C. Pressed state | 8dp | 8dp | 12dp | 16dp | 16dp |

## Baseline tokens

Use the table's menu to select a token set. Filled, tonal, and outlined icon button tokens are now deprecated in favor of the new token sets. All other tokens are still available in the module at the top of the page.

<!-- section: Guidelines -->

_footer: Icon buttons can be a wide variety of sizes, shapes, and colors. When placed in a button group, adjacent icon buttons respond to one another when pressed._
_altText: Illustrative example of icon buttons in a variety of sizes and shapes._

## Usage

Use icon buttons to display common actions. There are two variants: **default** and **toggle**. 

-
Default icon buttons can open other elements, such as a menu or search.

-
Toggle icon buttons can represent binary actions that can be toggled on and off, such as **favorite** or **bookmark**.

Icon buttons can be placed directly on the background or in most container components, such as cards, app bars, and toolbars.

Multiple icon buttons can be placed in a standard button group to add interaction and motion between the buttons when pressed. [More about standard button groups](/m3/pages/button-groups/overview)

_footer: Icon buttons can be used within other components, such as in a toolbar or card_
_altText: Icon buttons in a toolbar._

### Color

There are four icon button color styles, in order of emphasis:

- Filled
- Tonal
- Outlined
- Standard

For the highest emphasis, use the filled style. For the lowest emphasis, use standard.

_footer: The default (left) and toggle (right) icon buttons are available in all four color styles_
_altText: Diagram of default and toggle icon buttons in 4 color styles._

Use a filled, tonal, or outlined icon button when the button needs more visual separation from the background.

Choose the right style and emphasis for the situation.

_footer: Use icons with a background to make them easy to see on any surface_
_altText: ‘Heart” icon on a background about a cooking show._

_footer: When mixing button variants, use color styles to make the primary action clear_
_altText: Text button and icon button in an app together._

Use the **filled** style for visual impact and key actions that require high emphasis.

Avoid overusing the filled style on a screen. Use them sparingly.

_footer: Use filled icon buttons for high emphasis actions, such as downloading or deleting_
_altText: Cards that swipe to reveal buttons with actions._

Use the **tonal** style as a middle ground between filled and outlined icon buttons. It’s useful for secondary actions paired with a high emphasis action.

For example, use the tonal style for actions like **Raise hand**in a video meeting. When selected, its visual emphasis is greater than the outlined menu button, but less than the filled **End call** button.

_footer: Leverage the different color styles to establish emphasis and direct people to important actions_
_altText: Icons found on the bottom of a telephone screen, including a “hang up” icon with a bright red tone._

Use the **outlined** style for medium-emphasis buttons. It’s useful when the button isn’t the main focus of the interaction, such as browsing through sets of cards.

Use the **standard** style for low-emphasis buttons, or when placing buttons on a colorful surface.

_footer: Outlined buttons indicate that more content is available without grabbing attention_
_altText: Left and right arrow outlined icon buttons indicating that more cards are available to browse._

### Size & width

Icon buttons are available in five different sizes:

- Extra small - 32dp
- Small - 40dp (default)
- Medium - 56dp
- Large - 96dp
- Extra large - 136dp

And three widths:

- Default
- Narrow
- Wide

Use size and width to provide emphasis and visual hierarchy in a page with multiple buttons. The main action should be the most visually prominent, whether through color or size, like starting and stopping a timer or playing and pausing a song.

_footer: Use different button colors and sizes to provide visual hierarchy and emphasize primary actions_
_altText: Variety of buttons in a timer app._

Not all icon buttons will need to emphasize a primary and secondary action. 

When buttons have a similar importance, they should be the same size.

_footer: When everything should have the same emphasis, use icon buttons that are the same size_
_altText: Uniform button sizes in a calculator app._

## Anatomy

_footer: - Icon - Container_
_altText: Diagram of anatomy of outlined, standard, and filled icon buttons._

### Icon

Icons visually communicate the button’s action. Their meaning should be clear and unambiguous. [Browse popular icons](https://fonts.google.com/icons)

Default icon buttons should use filled icons.

Toggle buttons should use an outlined icon when unselected, and a filled version of the icon when selected.

_footer: Ensure the meaning of the icon is clear, such as a heart indicating Favorite_
_altText: “Heart” icon in a restaurant app._

#### Icon accessibility requirements

For selected toggle buttons, if a filled version of an icon doesn’t exist, increase the icon weight to semibold. If semibold doesn’t provide enough visual change, use bold.

This is to ensure that selection is communicated through at least two properties, rather than just color. This requirement doesn't apply to default non-toggle buttons.

_footer: Icons without a fill should be semibolded when selected_
_altText: Selected, semi-bold icon in a text editing app._

### Container

The container provides increased contrast and hierarchy in places that need more visual separation from the background or other elements.

_footer: The container provides visual separation from the background image_
_altText: Container separating a video call preview with actions you can take._

## Placement

Icon buttons are commonly used in other components, such as app bars and cards. 

These buttons should be used for common, easily understandable actions. 

Only use a few icon buttons at once.

_footer: App bars often contain icon buttons_
_altText: App bar with icon buttons._

In dense layouts, group popular actions by placing many icon buttons next to each other in components like a toolbar or button group. 

These components draw attention or add interaction between buttons.

_footer: A toolbar is a collection of icon buttons and other components_
_altText: Toolbar with icon buttons and FAB._

## Behavior

### Hover

On hover, the icon button displays a tooltip describing its action, rather than the name of the icon itself.

_footer: The tooltip label text should be clear and concise_
_altText: The text Add to favorites appears as a tooltip when the curser is placed on a heart shaped icon._

### Selection

Toggle icon buttons allow a single choice to be selected or deselected, such as adding or removing something from favorites. 

When placed in a button group, icon buttons change shape to help the selected button stand out.

[More on button groups](/m3/pages/button-groups/overview)

_footer: Use toggle icon buttons when the icon can be selected_
_altText: A star-shaped toggle icon button to add or remove a song from favorites._

_footer: Don’t use toggle icon buttons for actions that don’t have a selected state, such as an icon button for an overflow menu_
_altText: A toggle icon button to open an overflow menu._

The icon should become filled to represent selection.

If a filled version of the icon doesn't exist, use semibold weight instead.

_footer: When making a selection, such as bookmarking or saving a video, the icon transitions from outlined (unselected) to filled (selected)_
_altText: An outlined-style bookmark icon in an unselected state changing to a filled-style selected state._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Understand meaning of the icon
- Navigate to and activate an icon button
- When applicable, a tooltip should be available to help describe the icon button's purpose

## Interaction & style

Ensure the icon has contrast of at least 3:1 with the surface or background.

_footer: Icon buttons should have a 3:1 contrast ratio with the surface or background_
_altText: Icon button with correct contrast ratio._

_footer: Avoid using colors with contrast below 3:1_
_altText: Icon button with insufficient contrast ratio._

## Keyboard navigation

**Keys** | **Actions** |
Tab | Focus lands on (non-disabled) icon button |
Space or Enter | Activates the (non-disabled) icon button |

## Labeling elements

The accessibility label for icon buttons describes the action the button is executing, such as **Add to favorites**, **Bookmark**, or **Send message**.

_footer: The icon button label describes the action, such as Add to favorites for the heart icon_
_altText: Icon button label and role._

## Layout & density

Groups of similar components can be nested together inside a component, or they can stand alone.

The target size of each icon button should be at least 48dp, even when nested.

_footer: Icon buttons can be used within other components, such as an app bar_
_altText: Icon buttons with 48dp target sizes._

### Avoid applying density by default

Don't apply density to icon buttons by default. This lowers their targets below the required 48x48 CSS pixels minimum size. 

Provide density options that allow people to choose a higher density, such as selecting a denser layout or changing the theme. Controls for adjusting density must maintain a target size of at least 48x48 CSS pixels.

## Hover

On web, icon buttons should display a tooltip with an accessibility label.

_footer: The tooltip label text should be clear and concise_
_altText: “Heart” icon with "Add to favorites" tooltip on hover._

---

<!-- Source: m3.material.io · components_segmented-buttons · updated 2026-07-17T07:05:19.536Z · CC-BY 4.0 (Google) -->

## Segmented buttons



<!-- section: Overview -->

starNote:Segmented buttons are no longer recommended in the Material 3 expressive update. For those who have updated, use the [connected button group](/m3/pages/button-groups/overview/) instead, which has mostly the same functionality but with an updated visual design.

-
Segmented buttons can contain icons, label text, or both

-
Two variants: single-select and multi-select

-
Use for simple choices between two to five items (for more items or complex choices, use chips)

_footer: - Single-select segmented button - Multi-select segmented button_
_altText: Two variants of segmented buttons._

## Availability & resources

## M3 Expressive update

**May 2025**

The segmented button is no longer recommended. Use the [connected button group](/m3/pages/button-groups/overview/) instead. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

## Differences from M2

-
**Color:** New color mappings and compatibility with dynamic color

-
**Icons:** Optional check icon to indicate selected state

-
**Layout:** Taller container height of 40dp

-
**Name and variants:** Segmented buttons were previously known as toggle buttons. They now have two official variants: single-select and multi-select.

-
**Shape:** Fully rounded corners

-
**Typography:**Labels use sentence case instead of all caps

_footer: Segmented buttons now have a container height of 40dp_
_altText: Diagram indicating the fully rounded corner radius of a segmented button._

_footer: M2: Segmented buttons had a small corner radius and label text in all caps_
_altText: Segmented buttons with M2 color mappings, all caps text labels, boxy shape, and shorter height._

_footer: M3: Segmented buttons have fully rounded corners, sentence-case text, different height, and new color mappings_
_altText: Segmented buttons with M3 color mappings, sentence case text labels, fully round shape, and taller height._

<!-- section: Specs -->

starNote: Segmented buttons are no longer recommended in the Material 3 expressive update. For those who have updated, use the [connected button group](/m3/pages/button-groups/overview/) instead, which has mostly the same functionality but with an updated visual design.

_footer: - Container - Icon (optional for unselected state) - Label text_
_altText: Diagram of segmented button indicating 3 parts of its anatomy._

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Segmented button color roles used for light and dark schemes:  - On surface - Outline - Secondary container - On secondary container_
_altText: Diagram of segmented button indicating its color mappings_

## States

States are visual representations used to communicate the status of a component or interactive element.  [Learn more about interaction states](/m3/pages/interaction-states/overview)

### Unselected

_footer: Unselected button states:  - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Side by side view of segmented buttons with 5 unselected states._

### Selected

_footer: Selected button states:  - Selected - Hovered on selected - Focused on selected - Pressed on selected_
_altText: Side by side view of segmented buttons with 4 selected states._

## Measurements

_footer: - Padding and container size - Target size_
_altText: Diagram indicating layout values, paddings, and target size for segmented buttons_

Attribute | Value |
Container width
 | Dynamic based on labels |
Segment width | Container width / total segments (Example: 1/3) |
Height
 | 40dp |
Outline width | 1dp |
Label alignment
 | Center |
Left/right padding
 | Min 12dp |
Padding between elements
 | 8dp |
Target size | 48dp |

### Density

Density can be used in denser UIs where space is limited. Density is only applied to the height.

_footer: Each step down in density removes 4dp from the height_
_altText: Side by side view of segmented buttons with 4 different density heights_

<!-- section: Guidelines -->

starNote:Segmented buttons are no longer recommended in the Material 3 expressive update. For those who have updated, use the [connected button group](/m3/pages/button-groups/overview/) instead, which has mostly the same functionality but with an updated visual design.

_footer: - Single-select - Multi-select_
_altText: Two types of segmented buttons._

## Usage

Segmented buttons help people select options, switch views, or sort elements.

_footer: A segmented button can help switch between viewing restaurant and bar options_
_altText: A segmented button for switching between restaurants and bar options._

There are 2 variants of segmented buttons:

-
Single-select

-
Multi-select

_footer: - Single-select segmented button can only have 1 segment selected - Multi-select segmented button can have multiple segments selected_
_altText: Side by side view of single and multi-select segmented buttons_

## Anatomy

_footer: - Segment - Container - Icon (optional) - Label text (optional) - Selected icon_
_altText: Diagram of segmented button indicating 5 parts of its anatomy_

### Segments

Segmented buttons can have 2-5 segments. Each segment is clearly divided and contains label text, an icon, or both.

_footer: There can be anywhere from 2 to 5 segments in single-select and multi-select segmented buttons_
_altText: Side by side view of segmented buttons each with additional segment starting from 2 to 5_

_footer: Segmented buttons are best used for selecting between 2 and 5 choices_
_altText: Mobile UI of data usage screen with segmented button_

_footer: Don’t use more than five segments in a single segmented button. Choices should be scoped. If you have more than five choices, consider using another component, such as chips._
_altText: Incorrect use of segmented button with 6 segments_

### Container

Like common buttons, segmented buttons have fully rounded corners by default.

_footer: Segmented buttons have fully rounded corners_
_altText: Close up detail of segmented button with fully rounded corners_

### Icons

Icons may be used as labels by themselves or alongside text. 

If an icon is used without label text, it must clearly communicate the option it represents.

_footer: Segmented buttons can include icons_
_altText: Side by side view of segmented buttons with different configurations of icons and label text_

### Label text

Labels should be short and succinct. If a label is too long to fit within its segment, consider using an icon alone.

_footer: Use labels that are as clear and short as possible_
_altText: Mobile UI of music app showing a segmented button with options for music, albums, podcasts_

_footer: Keep labels short and consistent in length_
_altText: Segmented button with options for day, week, month_

_footer: Don’t allow segments to wrap onto a new line_
_altText: Segmented button with 4 segments. 3 are next to each other. The 4th is wrapped on a new line._

_footer: Use consistent label types_
_altText: Segmented button with text labels reading day, week, month_

_footer: Icons can be used in place of labels, but they must clearly communicate their meaning_
_altText: Segmented button with icons only labels for walking, transit, driving_

_footer: Avoid mixing icon-only labels with text labels. Choose one label type and use that type for all segments._
_altText: Segmented button with 2 icon only options indicating favorite and bookmark and 3rd option with text label reading recent_

## Single-select

Use a single-select segmented button to select one option from a set, switch between views, or sort elements from up to five options. 

For example, use a single-select segmented button to choose one of a set of sizes, such as this beverage size selector.

_footer: A single select segmented button for choosing beverage size_
_altText: Mobile UI for ecommerce app with segmented button with 3 beverage size options_

## Multi-select

Use a multi-select segmented button to select or sort from two to five options. Unlike single-select, selection is not required and a user may concurrently select anywhere from all to none of the options. 

For example, multi-select segmented buttons can be used to filter by price range when searching for a restaurant.

_footer: A multi-select segmented button for filtering restaurant search options_
_altText: Mobile UI for ecommerce app with multi-select segmented button with 4 price range options_

## Placement

Segmented buttons should have adequate margins from the edge of the viewport or frame. 

On larger screens, set a maximum padding for all button segments so the set doesn't fill the screen.

_footer: Allow adequate space for margins. The button container shouldn’t reach the edge of the viewport._
_altText: Mobile UI with 2-segment segmented button and 4-segment segmented button each with same margins to the viewport edge._

_footer: Set a maximum padding within the segments to ensure usability on larger screens_
_altText: Game store UI with a segmented button the proper width_

_footer: Don’t allow segmented buttons to span the full width of larger screens or panes. This can leave too much padding on either side of the segment label, making the button less usable._
_altText: Game store UI with a segmented button improperly spanning the entire width of the screen_

Segmented buttons can be placed on other components, such as bottom sheets or full-screen dialogs.

_footer: A segmented button can be placed on a bottom sheet_
_altText: Mobile UI with segmented button in bottom sheet_

## Behavior

When using both icons and label text in segmented buttons, the icon label is replaced by the checkmark icon when the segment is selected.

_footer: Icons become checkmarks when selected in buttons that also use label text_
_altText: Segmented button with icon and text labels with checkmark icon in selected segment_

<!-- section: Accessibility -->

starNote:Segmented buttons are no longer recommended in the Material 3 expressive update. For those who have updated, use the [connected button group](/m3/pages/button-groups/overview/) instead, which has mostly the same functionality but with an updated visual design.

## Use cases

Users should be able to:

- Navigate to and activate segmented buttons with assistive tech
- Understand what each segment selection will do

### Interaction & style

For keyboard navigation, **Tab** focuses on an individual segment. 

For single-select segments, **Space** or **Enter** will select or unselect the focused segment.

For multi-select segments, **Space** or **Enter** will:

- select an un-selected segment
- select all of the segments
- un-select a selected segment

_footer: Use Tab to navigate through segments and Space/Enter to select/unselect._
_altText: Tab moves the focus through segments of a segmented button.  Space or enter selects and unselects segments._

### Color contrast

Segmented buttons are clusters of similar components, so the outline should have at least a 3:1 contrast ratio with the background or surface. This helps distinguish each button.

Both a checkmark icon and a color change are used to distinguish selection. Make sure color isn’t the only way to show selection.

_footer: Use an outline with a surface contrast of at least 3:1_
_altText: The outline of segmented buttons on the surface passes the minimum contrast of 3:1._

_footer: The segmented button shouldn't have a contrast outline less than 3:1_
_altText: The outline of segmented buttons on the surface fails the minimum contrast of 3:1._

### Initial focus

Focus will start in the first segment. Depending on the direction of the language, it is either the most left or the most right segment.

For single select and multi-select, the first segment will be focused regardless of selection state.

_footer: Focus begins on the left for left-to-right languages and on the right for right-to-left languages_
_altText: Segmented button focus starts on the left for left-to-right languages and on the right for right-to-left languages._

### Keyboard navigation
Keys | Actions (single select) | Actions (multi select) |
**Tab** | Focus lands on next enabled segment | Focus lands on next enabled segment |
**Space** or **Enter** | Select focused segment | Select and unselect focused segment |

### Labeling elements

The accessibility label for a segmented button comes from the visible label text on such as **Relevance** and **Distance**. 

If the segmented button displays icons without label text, the accessibility label describes the action that the button is expressing, such as **Inexpensive** for one currency symbol.

_footer: The label for segmented button matches the text label_
_altText: The the text and accessibility role for the left-most section of a segmented button following “sort by” is  is “relevance.”_

Single-select segmented buttons behave like radio buttons: only one option can be selected at a time. The label is **Radiogroup**.

Multi-select buttons behave like checkboxes: more than one option can be selected. The label is **Checkbox**.

_footer: The role for the multi-select segmented button is **Checkbox**_
_altText: Selected price range segmented buttons range from $ to $$$$. The accessibility label of the $ button is “inexpensive.”_

---

<!-- Source: m3.material.io · components_split-button · updated 2026-07-29T12:25:33.326Z · CC-BY 4.0 (Google) -->

## Split buttons



<!-- section: Overview -->

- Use to show an action with a menu of related actions
- Same size range as buttons and icon buttons: XS, S, M, L, XL

_footer: Split buttons are made of a common button and a menu icon button_
_altText: An extra large split button. It has a label and icon on one part of the button, and a menu icon on the other part._

## Availability & resources

## M3 Expressive update

**May 2025**

The split button has a separate menu button that spins and changes shape when activated. It can be used alongside other buttons of the same size. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

New component added to catalog.

Sizes:

- Extra small
- Small
- Medium
- Large
- Extra large

Color styles:

- Elevated
- Filled
- Tonal
- Outlined

_footer: Split buttons have the same five recommended sizes as label and icon buttons_
_altText: 5 sizes of split buttons._

<!-- section: Specs -->

## Variants

_altText: 1 type of split button._

Variant
 |
 M3
 |
M3 Expressive
 |

Split button

 |
--
 |
Available
 |

## Configurations

_footer: - Color configurations: Elevated, filled, tonal, outlined - Size configurations: XS, S, M, L, XL_
_altText: 4 colors and 5 sizes of split buttons._

Category
 |
Configuration
 |
 M3
 |
M3 Expressive
 |

Size

 |
XS, S, M, L, XL

 |
--
 |
Available
 |

Color

 |
Elevated, filled, tonal, outlined

 |
--
 |
Available

 |

## Tokens & specs

Use the table's menu to select a token set. Split button token sets are organized by size. [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: - Leading button - Icon - Label text - Trailing button_
_altText: 4 elements of a split button._

The leading button in split buttons can have an icon, label text, or both. The trailing button should always have a menu icon.

_footer: - Label + icon - Label - Icon_
_altText: 3 customizations of the leading button in the split button._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value.

Split buttons use the same color schemes as standard buttons. However, unlike toggle buttons, the split button color doesn’t change when selected—only a state layer is applied.

Split buttons use the same colors and state layers as buttons, shown in the following token module. [Go to buttons](/m3/pages/common-buttons/overview) for more details.

_footer: A: Unselected, B: Selected trailing icon  - Elevated - Filled - Tonal - Outlined_
_altText: 4 color roles of the split button when unselected and selected in light and dark theme._

## States

States are visual representations used to communicate the status of a component or an interactive element. 

Split button states use the same colors and state layers as buttons and icon buttons. Go to those specs for details.

### Leading button shape

The inner corners change shape for hovered, focused, and pressed states.

_footer: - Enabled - Disabled - Hovered - Focused - Pressed, pressed with focus_
_altText: 5 states of the leading button in the split button._

### Trailing button shape

The inner corners change shape for hovered, focused, and pressed states, and the icon becomes centered when selected.

_footer: - Enabled - Disabled - Hovered - Focused - Pressed, pressed with focus - Selected, selected with focus_
_altText: 6 states of the trailing menu button in the split button._

## Measurements

Text and icons are optically centered when the buttons are asymmetrical. They’re centered normally when symmetrical.

_footer: Menu icon offset when unselected:  - XS: -1dp from center - S: -1dp from center - M: -2dp from center - L: -3dp from center - XL: -6dp from center_
_altText: Padding and size measurements of the split button._

The inner corner radius changes depending on button sizing. The space should always be 2dp.

_footer: - Extra small 4dp - Small 4dp - Medium 4dp - Large 8dp - Extra large 12dp_
_altText: Inner padding and inner corner measurements of the split button._

<!-- section: Guidelines -->

_footer: Split buttons come in many sizes and colors_
_altText: Split buttons of many colors and sizes scattered._

## Usage

Split buttons are used to add a menu of actions alongside a main action. This reduces visual complexity by hiding extra options. Split buttons work well alone or alongside common buttons and icon buttons.

_footer: Split buttons on their own can grab attention_
_altText: A split button applied a filter of “Canada” to a list of activities. Three narrow buttons are next to it to share, favorite, and bookmark._

Split buttons have five recommended sizes. These sizes match the sizes offered on buttons and icon buttons:

-
Extra small

-
Small (default)

-
Medium

-
Large

-
Extra large

Scale up the split button in large breakpoints, or to create more emphasis in smaller windows.

_footer: Using large split buttons on small screens can add extra emphasis for hero moments_
_altText: A large split button in a compact window draws attention to buying an enamel mug in an online store._

Split buttons can be used alongside other buttons and button groups.

_footer: Split buttons work harmoniously with regular buttons_
_altText: A vibrant split button for starting a car drive is next to 2 muted icon buttons for bookmarking and sharing the trip._

Split buttons can be of different sizes from other buttons on the page, especially since they take up more space.

_footer: The most prominent controls can be larger while secondary controls in a split button can be smaller_
_altText: A media player has a split button for changing the speed quickly, or opening a menu of options._

The split button typically opens a menu, but can be customized to open other components like cards.

_footer: Open a menu from a split button_
_altText: A split button opens a menu with a vibrant color scheme._

_footer: Avoid modifying the menu in unusual ways_
_altText: A split button opens a menu with an irregular shape highlighting the selected item._

## Anatomy

_footer: - Leading button - Icon - Label text - Trailing button_
_altText: 4 elements of a split button._

The leading button should be brief, just one or two words, with an icon that best matches the action.

The trailing button should always have the expand and collapse icon since it rotates when selected. Avoid modifying the icon.

_footer: Avoid using very long labels or changing the trailing icon_
_altText: A split button for starting driving directions has a label “32 minutes away” and a refresh icon instead of a menu icon._

In right-to-left languages, the component layout is mirrored.

_footer: Split buttons mirror the order of elements in right-to-left languages_
_altText: The split button elements are reversed in a right-to-left language._

## Behavior

The split button uses the standard motion scheme (not the expressive motion scheme) when rotating the menu button.

The menu button rotates inwards 180° when opened and closed.

_footer: Selecting the menu button rotates the icon inwards and applies shape morph_
_altText: The trailing menu button spins 180° to point up, and applies a 10% state layer when selected._

### Menu placement

When using the split button with a menu, align the menu with the trailing button when possible.

_footer: Align the menu with the trailing button_
_altText: A split button with an open menu. The leading edge of the menu is aligned to the leading edge of the menu button._

If there’s not enough room, align the menu to one of the sides of the button.

_footer: If not possible, align the menu to the side of the leading or trailing button_
_altText: A split button with an open menu. The trailing edge of the menu is aligned to the trailing edge of the menu button._

Depending on breakpoint, scroll position, and other factors, the menu may need to appear elsewhere around the button. Always try to align it with one of the edges of the button.

The menu should be 4dp from the split button.

_footer: - Top aligned to trailing button - Bottom aligned to trailing button - Top right-aligned - Top left-aligned - Bottom right-aligned  - Bottom left-aligned_
_altText: 6 other ways the menu can align to the split button._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate to each button and interact with them
- Navigate to any element opened by the trailing button
- Understand the current selection state of the button

## Interaction & style

Each button in the split button needs a minimum target area of 48x48dp. Extra small and small split buttons are shorter than 48dp, so the target areas around them need to be at least 48dp tall.

_footer: Target areas should be at least 48x48dp   - Extra small - Small_
_altText: Diagram showing extra small and small split buttons with visible 48x48dp target areas._

## Initial focus

Focus should land on the leading button then move to the trailing button. This can depend on the operating system’s settings.

_footer: - Left to right - Right to left_
_altText: Focus on the leading button and trailing button for both LTR and RTL languages._

## Keyboard navigation

Keys
 | Actions
 |
Tab | Navigate between buttons |
Space or enter | Activate focused button |

## Labeling elements

The accessibility label for the leading button is the same as buttons.

_footer: Leading buttons should have the same labels as common buttons_
_altText: “Watch later” is both the button label text and the accessibility label._

The trailing icon button should have an extra state or similar label indicating that the menu is expanded or collapsed.

Label the button to clearly indicate that there are more options. The label of the secondary button should indicate that it provides additional choices related to the action of the main button. For instance, if the main button says "Watch later," the secondary button should be something like "More watch options."

Label the opened menu according to the [menu accessibility guidance](/m3/pages/menus/accessibility/).

_footer: Trailing buttons should communicate the state of the menu and that more options are available_
_altText: Collapsed state indicated for the trailing button._

---

<!-- Source: m3.material.io · components_floating-action-button · updated 2026-07-27T13:59:42.096Z · CC-BY 4.0 (Google) -->

## FABs



<!-- section: Overview -->

-
Use a FAB for the most common or important action on a screen

-
Make sure the icon in a FAB is clear and understandable

-
FABs persist on the screen when content is scrolling

-
Three variants: FAB, medium FAB, large FAB

_footer: - FAB  - Medium FAB  - Large FAB_
_altText: The 3 sizes of floating action buttons._

## Availability & resources

## M3 Expressive update

**May 2025**

The FAB has new sizes to match the extended FAB and more color options. The small FAB is no longer recommended. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
Added **medium** FAB size

-
**Small** FAB size is no longer recommended

-
FAB and large FAB sizes are unchanged

-
FAB variants are based on size, not color

Color:

-
Added tone color styles: 

Primary

-
Secondary

-
Tertiary

-
Renamed existing tonal color styles to match their token names: 

**Primary** to **Primary container**

-
**Secondary** to **Secondary container**

-
**Tertiary** to **Tertiary container**

-
The values haven't changed

-
Surface color FABs  are no longer recommended

_footer: FABs have updated colors and sizes_
_altText: 4 FABs showing the colors available after the expressive update._

## Differences from M2

_footer: M2: FABs are circles and always have a drop shadow_
_altText: M2 circular FAB with a plus icon._

_footer: M3: FABs have a boxier shape, can use dynamic color, and include a new large FAB variation_
_altText: M3 rounded corner square FAB with an artist’s palette icon._

<!-- section: Specs -->

## Variants

_footer: - FAB - Medium FAB - Large FAB_
_altText: An icon on the container of a FAB, medium FAB, and large FAB._

### Baseline variants

The small FAB is still available, but no longer recommended. [Jump to baseline specs](/m3/pages/fab/specs#cd336045-e97d-4a6d-ac23-f778fa695e3c)

_footer: 1. Small FAB_
_altText: An icon on the container of a small FAB._

Variant
 |
M3
 |
M3 Expressive
 |

FAB
 |
Available
 |
Available
 |

Medium FAB
 |
--
 |
Available
 |

Large FAB
 |
Available
 |
Available
 |

Small FAB
 |
Available
 |
Not recommended.

Use a larger size.
 |

## Configurations

In the expressive update, the **primary**, **secondary**, and **tertiary** set colors were renamed to **primary container**, **secondary container**, and **tertiary container**to match the actual color roles used. New primary, secondary, and tertiary color styles were created to match the corresponding color roles. [View details in the color styles section](/m3/pages/fab/specs#67e71ec7-b520-405a-aa06-2decfa0b92a3)

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Color
 |
Primary container, secondary container, tertiary container
 |
Available as primary, secondary, tertiary
 |
Available
 |

Primary. secondary, tertiary
 |
--
 |
Available
 |

## Tokens & specs

Use the table's menu to select a token set. FAB tokens are organized by size and color. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: 1. Container  2. Icon_
_altText: 2 elements of the FAB._

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens)

### Color styles

FABs can use several combinations of **color** and **on-color** styles, such as **primary** and **on-primary**. The following color mappings provide the same legibility and functionality, so the color mapping you use depends on style alone.

_footer: - Primary container & On primary container (default) - Secondary container & On secondary container - Tertiary container & On tertiary container - Primary & On primary - Secondary & On secondary - Tertiary & On tertiary_
_altText: 6 FAB color styles in light and dark themes. Each style has 2 color roles, 1 for the container and icon._

### Baseline color styles

Surface FAB color styles are still available, but no longer recommended.

_footer: - Surface FABs_
_altText: Baseline FAB style in all 3 sizes._

## States

States are visual representations used to communicate the status of a component or interactive element.

When using a non-default color mapping for FABs, make sure the state layer color is the same as the icon color. For example, the state layer color for the **primary** color style should be md.sys.color.primary.

_footer: - Enabled - Hovered (8% state layer) - elevation 4 - Focused (10% state layer) - Pressed (10% state layer)_
_altText: 4 states of a FAB shown in light and dark themes._

## Measurements

### FAB

_footer: FAB size measurements_
_altText: FAB size measurements._

_footer: FAB padding measurements_
_altText: FAB padding measurements._

### Medium FAB

_footer: Medium FAB size measurements_
_altText: Medium FAB size measurements._

_footer: Medium FAB padding measurements_
_altText: Medium FAB padding measurements._

### Large FAB

_footer: Large FAB size measurements_
_altText: Large FAB size measurements._

_footer: Large FAB padding measurements_
_altText: Large FAB padding measurements._

## Baseline tokens & specs

Use the table's menu to select a token set. This only includes tokens for small and surface FABs, which are both no longer recommended. It doesn't include other colors, or large or regular FABs, since those are still currently used.

<!-- section: Guidelines -->

_footer: FABs have multiple sizes that scale with the breakpoint_
_altText: 3 screens with various FAB sizes._

## Usage

Use a FAB for the most important action on a screen; it appears in front of all other content.

The FAB can be aligned left, center, or right. It can be positioned above the navigation bar, or nested within it.

_footer: FABs can use dynamic color_
_altText: A Compose FAB is positioned above a nav bar on a mobile email inbox._

There are three FAB sizes:

-
FAB

-
Medium FAB (most recommended)

-
Large FAB

Choose the FAB size based on the visual hierarchy of your layout. 

Note: The small FAB is no longer recommended.

_footer: - FAB  - Medium FAB - Large FAB_
_altText: 3 FAB sizes._

The FAB is the smallest size, and is best used in compact windows where other actions may be present on screen.

The medium FAB is recommended for most situations, and works best in compact and medium windows. Use it for important actions without taking up too much space. 

A large FAB is useful in any window size when the layout calls for a clear and prominent primary action, but is best suited for expanded and larger breakpoints, where its size helps draw attention.

_footer: Use a medium FAB in most breakpoints_
_altText: A medium FAB over an email app UI._

_footer: Use a large FAB when the primary action needs to be prominent_
_altText: A large FAB over an email app UI._

_footer: FABs are not needed on every screen, such as when images represent primary actions_
_altText: A photo feed with no FAB._

_footer: Don't display multiple FABs on a single screen_
_altText: A screen with 3 FABs makes it hard to tell what the primary action should be._

A FAB can transform into an extended FAB on larger screens, or it can transition into a FAB menu when selected. Use a FAB menu when there are many kinds of actions relevant to the FAB. 

[More on FAB menus](/m3/pages/fab-menu)

_footer: Use the extended FAB when label text is necessary_
_altText: A extended FAB saying “Share” with a less popular share icon._

_footer: Use the FAB menu when there are many kinds of actions relevant to the FAB_
_altText: A FAB menu showing 3 actions related to sharing._

## Actions

A FAB can trigger an action on the current screen, or it can perform an action that creates a new screen.

A FAB promotes an important, constructive action such as:

- Create
- Favorite
- Share
- Start a process

_footer: Use FABs for primary, positive actions_
_altText: FABS for 12 common actions including, create, edit, and navigate._

Avoid using a FAB for minor or destructive actions, such as:

-
Archive or trash

-
Alerts or errors

-
Limited tasks like cutting text

-
Controls better suited to a toolbar, like to adjust volume or font color

_footer: Don’t use FABs for minor, overflow, unclear, or destructive actions_
_altText: FABs for 18 minor or destructive actions, such as cut, trash, and volume._

## Anatomy

_footer: - Container - Icon_
_altText: 2 elements of a FAB._

### Container

The FAB is typically displayed in a square container. The container shouldn’t be covered by other elements, such as badges.

The container must have sufficient color contrast with the surface it’s placed on.

_footer: A FAB container color needs to stand out from its background_
_altText: A bright colored FAB has high contrast with the background._

### Icon

An icon in a FAB should be clear and understandable. When hovering over a FAB on web products, FABs should display a tooltip with an accompanying icon text label. Use a filled icon instead of an outlined icon.

A FAB shouldn't contain notifications or actions found elsewhere on a screen.

_footer: Use clear and simple icons such as add, message, or edit_
_altText: 4 FABs each with a simple icon._

_footer: Don’t use confusing or open-ended icons to symbolize less common actions_
_altText: 4 FABs each with an ambiguous icon._

## Adaptive design

In compact and medium breakpoints, the best place for the FAB is typically the lower right corner of a screen, since it’s easy to reach and is less likely to cover important content.

In expanded breakpoints, consider placing the FAB in the upper left corner, like in the navigation rail. This positions it as one of the first interactive elements people see when they land on the page.

Adjust the size of the FAB based on the context. Use a medium FAB for mobile layouts, and large FAB for tablets and large screens.

_footer: For large screens, place the FAB in the upper left corner_
_altText: Large screen layout showing FAB in upper left region of the screen, below navigation rail icon._

_footer: A FAB can be used within a navigation component, such as a navigation rail_
_altText: A screen layout with several interactive elements. A single FAB is in the navigation rail._

_footer: Individual components, such as cards, shouldn’t have their own FAB_
_altText: A busy screen layout with 8 cards, each with their own FAB._

## Behaviors

### Appearing

When a FAB animates on screen, it expands outward from a central point. The icon within it can be animated as well.

While FABs should be relevant to screen content, they aren't attached to the surface on which content appears. FABs move separately from other UI elements because of their relative importance.

**Screen transitions**FABs can morph to launch related actions. When a screen changes its layout, the FAB should disappear and reappear during the transition.

**Reappearance**The FAB should only reappear if it's relevant to the new screen. It should reappear in the same position, if possible.

_footer: FAB animating on screen_
_altText: FAB appearing from the bottom of the screen, moving to a position above the  navigation bar._

### Expanding

The FAB can expand and adapt to any shape using a container transform transition pattern. This includes a surface that's part of the app structure, or a surface that spans the entire screen.

The FAB can also transition into a FAB menu. 

[More on FAB menus](/m3/pages/fab-menu)

_footer: FABs can expand and adapt to any shape_
_altText: Compose FAB expands to container size, opening a draft email screen._

### Scrolling

FABs remain in place on scroll.

Extended FABs can collapse into a FAB on scroll and expand on reaching the bottom of the view.

_footer: FABs stay in place above a scrolling background_
_altText: Extended FAB collapsed into a FAB when scrolling on the page._

### Moving across tabs

When tabs are present, the FAB should briefly disappear, then reappear when the new content moves into place. This shows that the FAB is not connected to any particular tab.

_footer: The FAB should disappear and reappear when switching pages_
_altText: FAB blinks away and reappears with new screen content._

Don't animate the FAB with body content.

_footer: Don’t keep the FAB on screen when switching pages_
_altText: FAB moves horizontally when scrolling between tabs._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

-
Navigate to and activate the FAB 

-
Perform an action with the FAB 

-
Expand and minimize an extended FAB

## Interaction & style

Don't disable the FAB. If the action represented in the FAB is unavailable, the FAB shouldn't appear.

Ensure the icon has a minimum 3:1 contrast ratio with the container.

_footer: FAB icons are above the 3:1 contrast ratio_
_altText: FAB with highly contrasting bright container and dark icon._

_footer: Avoid using colors with a contrast below 3:1_
_altText: FAB with low-contrasting dark container and dark icon._

## Focus

Ensure the FAB is prioritized in the overall focus order to create an efficient experience for people who navigate UIs with assistive tech. 

On mobile, the focus order may start with the app bar, move to the navigation bar, and then skip past any other content on the page to land on the FAB.

Consider displaying a tooltip when the FAB is focused. This is supported on web.

_footer: Tooltips surface the FAB’s label when focused_
_altText: A focused FAB with a tooltip saying “Compose” appearing below it._

## Layout & position

To make it easier for users of screen readers to reach a primary action such as a FAB on expanded breakpoints, consider placing the FAB in the upper left region. 

However, it’s critical to test placement options with users to see if the upper left region is the best position in all browser windows. For compact and medium breakpoints, the best place for the FAB is the lower right corner of a screen.

_footer: In compact windows, place the FAB in the bottom trailing edge_
_altText: FAB in the lower right region of a small screen._

_footer: In expanded windows, place the FAB in the navigation rail_
_altText: FAB in the upper left region of a large screen._

To ensure accessibility for keyboard users on the web, avoid positioning the FAB in a way that completely obscures the focus indicator of an actionable element. 

It’s okay to partially cover the desired element, as long as the focus indicators are still visible.

_footer: The FAB can partially cover an actionable element, as long as the focus indicator is still clearly visible_
_altText: FAB in the lower right region doesn’t obscure the focus indicator of an actionable icon._

_footer: Don’t completely obscure an actionable element and its focus indicator_
_altText: FAB in the lower right region obscures an actionable icon and its focus indicator._

## Keyboard navigation

**Keys**
 |
**Actions**
 |

**Tab**
 |
Focus lands on the FAB
 |

**Space** or **Enter**
 |
Perform the default action on an item
 |

## Labeling elements

The accessibility label should describe the action that the button is performing, such as **Compose a new message**.

_footer: The accessibility label of the FAB with a pencil icon describes the action of composing a new message_
_altText: Accessibility label and accessibility role of a FAB._

---

<!-- Source: m3.material.io · components_extended-fab · updated 2026-07-27T13:55:35.429Z · CC-BY 4.0 (Google) -->

## Extended FABs



<!-- section: Overview -->

-
Use for the most common or important action on a screen

-
Three variants: small, medium, and large

-
Use instead of FAB when label text is needed to understand action

_footer: - Small extended FAB - Medium extended FAB - Large extended FAB_
_altText: 3 extended fab sizes._

## Availability & resources

## M3 Expressive update

**May 2025**

The extended FAB now has three sizes: small, medium, and large, each with updated type styles. These align with the FAB sizes for an easier transition between FABs. The baseline extended FAB is no longer recommended and should be replaced with the small extended FAB. Surface and FABs are also no longer recommended. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants and naming:

-
Added new sizes

Small: 56dp

-
Medium: 80dp

-
Large: 96dp

-
No longer recommended

Baseline extended FAB (56dp)

-
Surface extended FAB

Updates:

-
Adjusted typography to be larger

_footer: The baseline extended FAB is replaced with a set of small, medium, and large extended FABs with new typography_
_altText: The baseline extended FAB and the small, medium, and large extended FABs from the expressive update._

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Layout: Extended FAB is the same height as the FAB
- Shape: Boxier style with smaller corner radius

_footer: M2: Extended FABs are pill-shaped and have a different height and elevation_
_altText: Diagram comparing the M2 FAB and extended FAB._

_footer: M3: Extended FABs share the same height, boxier shape, and simpler elevation model as FABs_
_altText: Diagram comparing the M3 FAB and extended FAB._

<!-- section: Specs -->

## Variants

_footer: - Small extended FAB - Medium extended FAB - Large extended FAB_
_altText: 3 variants of extended FABs._

### Baseline variants

The baseline extended FAB is no longer recommended in the M3 expressive update. Use a small extended FAB; the type style was updated from **label large** to **title medium**, and the inner padding was reduced. [View baseline extended FAB specs](/m3/pages/extended-fab/specs#01e114e6-8c3d-4d39-9376-65aa5c10e01b)

_footer: - Extended FAB_
_altText: 1 baseline extended FAB._

Variant
 |
M3
 |
M3 Expressive
 |

Small extended FAB
 |
--
 |
Available
 |

Medium extended FAB
 |
--
 |
Available
 |

Large extended FAB
 |
--
 |
Available
 |

Extended FAB (baseline) 
 |
Available
 |
Not recommended.
Use **small extended FAB.**

 |

## Tokens & specs

Use the table's menu to select a token set. Extended FAB tokens are organized by size and color.

## Anatomy

_footer: - Container - Label text - Icon_
_altText: 3 elements of extended FABs._

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

### Color styles

Extended FABs can use several combinations of **color** and **on color** styles, such as **primary** and **on primary**. The following color mappings provide the same level of contrast and functionality, so choose a color mapping based on visual preference.

_footer: Extended FAB color roles used for light and dark schemes:  - Primary container & on primary container (default) - Secondary container & on secondary container - Tertiary container & on tertiary container - Primary & on primary - Secondary & on secondary - Tertiary & on tertiary_
_altText: 6 extended FAB color styles._

### Baseline color styles

Extended FABs should no longer use surface color styles. They’re still available, but not recommended.

_footer: - Surface container FAB_
_altText: 1 baseline extended FAB color style._

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

When using a non-default color mapping for extended FABs, make sure the state layer color is the same as the icon color. For example, the state layer color for primary mapping should be md.sys.color.primary.

_footer: - Enabled - Hovered - elevation 4 - Focused - Pressed_
_altText: 4 states of extended FABs._

## Measurements

_footer: Size and padding measurements of the small, medium, and large extended FABs_
_altText: Extended FAB padding and size measurements._

_footer: Extended FABs should have margins of 16dp_
_altText: Extended FAB margin measurements._

## Baseline extended FAB

_footer: - Container - Label text - Icon_
_altText: 3 elements of baseline extended FAB._

### Baseline configurations

_footer: With icon_
_altText: Baseline extended FAB with icon._

_footer: Without icon_
_altText: Baseline extended FAB without icon._

### Baseline tokens

Use the table's menu to select a token set. The baseline extended FAB token sets are organized by common tokens, then by surface and branded color styles. Other color styles like primary, secondary, and tertiary are still used by the latest extended FABs.

### Baseline colors

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Extended FAB color roles used for light and dark schemes:  - Primary container + shadow - On primary container - On primary container_
_altText: 3 baseline extended FAB color roles._

#### Additional color mappings

Extended FABs can use other combinations of container and icon colors. The color mappings below provide the same legibility and functionality as the default, so the color mapping you use depends on style alone.

_footer: Extended FABs can use different combinations of container and icon colors_
_altText: 3 deprecated extended FABs with different container and icon colors._

### Baseline states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

_footer: - Enabled - Hovered - Focused - Pressed_
_altText: 4 states of baseline extended FAB._

### Baseline measurements

_footer: Extended FABs have a padding of 16dp_
_altText: Margins of baseline extended FAB._

_footer: Extended FAB height, width, and icon size_
_altText: Size of baseline extended FAB while on screen._

Attribute | Value |

Container height
 |
56dp
 |

Container width
 |
Dynamic, 80dp min
 |

Container shape
 |
16dp corner radius
 |

Icon size
 |
24dp
 |

Padding
 |
16dp
 |

<!-- section: Guidelines -->

_footer: Extended FABs are more prominent than regular FABs_
_altText: Vibrant extended FAB on an email screen._

## Usage

Use an extended FAB on screens with long, scrolling views that require persistent access to an action, such as a checkout screen. 

Use it when label text helps understand the main action, or to add further emphasis to the button.

_footer: Extended FABs ensure the main action is visible at all times_
_altText: A centered extended FAB is used to check out in a shopping app._

_footer: Use an extended FAB to provide constant access to a primary action above long-scrolling surface content_
_altText: Extended FAB on an article with lots of body content to publish that article._

_footer: Use an extended FAB to emphasize a page’s primary action_
_altText: Extended FAB on a task list to create a new task._

### Additional emphasis

The extended FAB can provide more emphasis and clarity to a product’s primary action. 

Since it has room for both a text label and icon, the extended FAB can be effective where an icon alone is ambiguous. However, the relationship between an extended FAB's icon and label should be clear.

_footer: An extended FAB can be effective where an icon alone is too vague_
_altText: Extended FAB labeled “find flights” with an airplane icon, which would be unclear on its own._

Like the regular FAB, only one extended FAB should be used per screen. 

Multiple FABs compete for attention. 

If additional high-level actions are required, consider adding more buttons elsewhere on the page.

_footer: Only show one prominent action at a time with the extended FAB_
_altText: An extended FAB used on a screen._

_footer: Don’t use multiple extended FABs in one screen as it disrupts visual hierarchy_
_altText: 2 extended FABs used on 1 screen._

The extended FAB shouldn't be used as an option in a set of actions. 

Instead, use filled buttons for a similar level of emphasis.

_footer: Use a button with appropriate styling to emphasize it in a group of buttons_
_altText: Filled button labeled “finish setup” next to a “back” button._

_footer: Don’t use the extended FAB to convey an option in a set of actions_
_altText: Extended FAB labeled “finish setup” next to a “back” button._

### Choosing a size

There are three variants of extended FABs: small, medium, and large.

Choose an appropriately-sized extended FAB to add the right amount of emphasis for an action. 

In compact windows with one prominent action, the large extended FAB can be appropriate.

In larger breakpoints, use a medium or large extended FAB.

_footer: There are three sizes of extended FABs_
_altText: 1 large, 1 medium, and 1 small extended FAB on 3 different screen sizes._

## Anatomy

_footer: - Container - Label text - Icon (optional)_
_altText: 3 extended FAB elements._

### Container

The extended FAB container is a rounded rectangle that hugs its contents. 

The extended FAB grows and shrinks with text length.

_footer: The extended FAB container hugs the icon and text_
_altText: Fixed-width extended FAB, centered, ignoring layout grid._

### Icon (optional)

An extended FAB's icon should intuitively represent its action.

_footer: Unlike standard FABs, extended FABs don't require an icon_
_altText: Extended FAB without an icon, labeled “Save draft”._

_footer: An extended FAB can't have an icon without a text label_
_altText: Extended FAB with icon only, with no label text._

### Label text

The extended FAB’s label should clearly describe its action.

Use 1–2 words at most. Keep in mind that localization may increase the amount of characters and width of the extended FAB.

_footer: Shorten the text as much as needed. Include an icon for additional context._
_altText: Extended FAB with short text “Save”._

_footer: Avoid wrapping or truncating text_
_altText: Extended FAB with wrapping text “Save draft in folder”._

## Placement

_footer: Place the extended FAB above the rest of the UI, off of elements like app bars_
_altText: Extended FAB placed above navigation bar._

_footer: Don’t place the extended FAB on top of toolbars. It disrupts the consistency of the elevation and surface layers._
_altText: Extended FAB overlaid on a docked toolbar._

_footer: Don’t place the extended FAB in the upper half of a mobile screen, as it disrupts the reading of the UI_
_altText: Extended FAB below an app bar at the top of a mobile screen._

_footer: Don’t place extended FABs on cards or inside other containers_
_altText: An extended FAB labeled "Confirm" on a dialog to "Confirm your location"._

Avoid putting other floating components, like the floating toolbar, on screen with the extended FAB.

_footer: Floating toolbars can be paired with FABs, but not extended FABs_
_altText: The extended FAB is next to a floating toolbar._

## Responsive layout

The FAB and extended FAB can transform into each other depending on available space and layout. 

In a collapsed navigation rail, a FAB would be used. When the rail is expanded, the FAB can transform into an extended FAB.

_footer: When space is limited, an extended FAB can transform into a FAB_
_altText: Example of extended FAB transforming into standard FAB._

### Right-to-left languages

Extended FABs should mirror their elements in right-to-left (RTL) languages.

_footer: Icons should be placed to the left of labels for left-to-right (LTR) languages_
_altText: Extended FAB in a left-to-right language placed at the bottom right of a screen. The icon is to the left of the text._

_footer: Icons should be placed to the right of labels for RTL languages_
_altText: Extended FAB in a right-to-left language placed at the bottom left of a screen. The icon is to the right of the text._

### Breakpoints

In compact and medium breakpoints, the extended FAB should be placed at the bottom of the screen, either center-aligned or aligned to the trailing edge of the window.

_footer: The extended FAB can be center-aligned_
_altText: Extended FAB center-aligned on a mobile screen._

_footer: The extended FAB can be aligned to the trailing edge of the window_
_altText: Extended FAB right-aligned on a mobile screen._

In expanded and larger breakpoints, the extended FAB should appear either:

-
At the bottom right edge of the window, in both LTR and RTL languages

-
Within the navigation rail

_footer: The extended FAB can be right-aligned in both LTR and RTL languages_
_altText: Extended FAB at bottom right of screen._

_footer: The extended FAB can be at the top of the expanded navigation rail_
_altText: Extended FAB in navigation drawer._

## Behavior

### Appearing

The extended FAB surface expands when appearing on screen using an [enter and exit](/m3/pages/motion-transitions/transition-patterns#e1c2a650-d7a4-4a6d-9025-e6b7845291ed) transition pattern.

_footer: An extended FAB expands when appearing on screen_
_altText: Extended FAB appearing on screen._

### Expanding

The extended FAB can expand and adapt to any shape using a [container transform](/m3/pages/motion-transitions/transition-patterns) transition pattern. 

This includes a surface that is part of the app structure, or a surface that spans the entire screen.

_footer: An extended FAB can expand and adapt to any shape_
_altText: Extended FAB adapting to various shapes._

### Transforming

The extended FAB can transform into a FAB on scroll to temporarily take up less space on screen.

_footer: An extended FAB can transform into a FAB_
_altText: Extended FAB transforming into a FAB when the page is scrolled._

### Scrolling

The extended FAB can transform into a FAB when scrolling down, and back to an extended FAB when scrolling up.

_footer: An extended FAB collapses and expands when scrolling_
_altText: Extended FAB transforming while scrolling._

When the FAB switches to an extended FAB, the following transitions occur:

- The FAB shape changes
- FAB icon moves to the left
- FAB text label fades in

_footer: FAB switches to an extended FAB_
_altText: FAB transforming into extended FAB._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate to and activate the extended FAB

## Interaction & style

To make it easier for users of screen readers to reach a primary action such as an extended FAB, consider placing the action in the upper left region of large web screens, like in an expanded navigation rail.

In smaller windows, the best place for the extended FAB is the lower right corner of a screen.

_footer: Extended FABs can be placed in the expanded navigation rail_
_altText: On a large screen, the Compose FAB is placed on the upper left region in an email app with the expanded window on the right._

_footer: Place extended FABs in an easy-to-reach place that doesn’t obstruct other actions_
_altText: In a compact window, the Compose FAB is placed on the lower right region in an email app._

_footer: Don’t place extended FABs over another actionable element_
_altText: In a compact window, the Compose FAB is overlapping other buttons in an email app._

## Initial focus

Ensure the extended FAB is prioritized in the overall focus order to create an efficient experience for people who navigate UIs with assistive tech. 

On mobile, the focus order may start with the app bar, move to the navigation bar, and then skip past any other content on the page to land on the extended FAB.

When using an extended FAB, both the visible label and icon should be treated as one focusable element. The extended FAB doesn’t need a tooltip because it already has a visible label.

_footer: Ensure extended FABs get focus when navigating with assistive technology_
_altText: A focused extended FAB in the lower right region of a mobile screen._

_footer: Tooltips aren’t required since the extended FAB has label text_
_altText: A focused extended FAB with a tooltip matching the text label._

## Keyboard navigation

Keys | Actions |
**Tab** | Moves focus to the extended FAB |
**Space**or **Enter**
 | Activates the extended FAB |

## Labeling elements

To ensure the action is clear, use consistent icons and text labels, such as a **Compos****e**icon with a **Compose** text label. 

The icon and text label combination should have one distinct purpose.

The accessibility label must include the same first word as the visible label. For example, if the visible button is **Create**, then the accessibility label might say **Create a new invite**.

_footer: The accessibility label reads **Compose**to match the extended FAB's displayed label_
_altText: Accessibility labels of an extended FAB._

---

<!-- Source: m3.material.io · components_fab-menu · updated 2026-07-17T06:58:41.835Z · CC-BY 4.0 (Google) -->

## FAB menu



<!-- section: Overview -->

- Opens from a FAB to show 2–6 related actions floating on screen
- One FAB menu size for all sizes of FABs
- Not used with extended FABs
- Available in primary, secondary, and tertiary color sets

_footer: The FAB menu comes in three color sets: primary, secondary, tertiary_
_altText: 3 FAB menus in different color schemes._

## Availability & resources

## M3 Expressive update

May 2025

The FAB menu adds more options to the FAB. It should replace the speed dial and any usage of stacked small FABs. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

New component added to catalog:

- One menu size that pairs with any FAB
- Replaces any usage of stacked small FABs

Color:

- Contrasting close button and item colors
- Supports dynamic color
- Compatible with any FAB color style

_footer: The FAB menu uses contrasting color and large items to focus attention. It can open from any size FAB._
_altText: 4 screens. The FAB menu is on the first, and 3 FABs of different sizes are on the others._

## Differences from M2

_footer: M2: The speed dial used small round FABs_
_altText: M2 speed dial._

_footer: M3: The FAB menu uses dynamic color and a larger item size_
_altText: GM3 FAB menu._

<!-- section: Specs -->

## Variants

_footer: There’s one variant of FAB menu_
_altText: The FAB menu in its single variant._

Variant
 |
 M3
 |
M3 Expressive
 |

FAB menu
 |
--
 |
Available
 |

## Configurations

_footer: Three color sets:  - Primary  - Secondary  - Tertiary_
_altText: 3 color configurations of FAB menus._

Category
 |
Configuration
 |
 M3
 |
M3 Expressive
 |

Color
 |
Primary set, secondary set, tertiary set
 |
--
 |
Available
 |

## Tokens & specs

Use the table's menu to switch token sets. The FAB menu has a common token set and six color sets, three for each element (close button and menu item). [Learn about design tokens](/m3/pages/design-tokens/overview/)

## Anatomy

_footer: - Close button - Menu item_
_altText: 2 elements of a FAB menu._

_footer: The FAB menu can have up to six items_
_altText: 5 FAB menus showing the range of 2–6 items._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: - On primary container - Primary container - On primary - Primary - On secondary container - Secondary container - On secondary - Secondary - On tertiary container - Tertiary container - On tertiary - Tertiary_
_altText: 12 colors of the FAB menu._

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

### Close button

_footer: Close button states in light and dark themes:   - Enabled  - Hovered  - Focused  - Pressed_
_altText: 4 states of the FAB menu close button._

### Menu item

_footer: Menu item states in light and dark themes:  - Enabled  - Hovered  - Focused  - Pressed_
_altText: 4 states of the FAB menu items._

## Measurements

FAB menu items share the same measurements as the medium button specs. 

The close button should always be 56dp.

_footer: FAB menu size measurements_
_altText: FAB menu size measurements._

The FAB menu animates from the top trailing edge of the FAB to ensure a smooth animation.

_footer: The FAB should always have 16dp margins_
_altText: FAB on a mobile screen with 16dp margins annotated._

_footer: The close button and FAB share the top trailing corner as an anchor and appear in the same place_
_altText: FAB menu opened from a FAB has matching margins of 16dp._

Larger FABs will place the FAB menu slightly higher, with larger margins underneath.

_footer: The medium FAB placement has 16dp margins_
_altText: Medium FAB on a mobile screen with 16dp margins annotated._

_footer: The close button is placed higher to align with the top of the medium FAB_
_altText: FAB menu opened from the medium FAB has a 40dp margin from bottom of screen._

_footer: The large FAB placement has 16dp margins_
_altText: Large FAB on a mobile screen with 16dp margins annotated._

_footer: The close button is placed higher to align with the top of the large FAB_
_altText: FAB menu opened from the large FAB has a 56dp margin from bottom of screen._

On web, the FAB menu opens from the FAB, and inherits its states and specs from the baseline menu component. 

The gap between the FAB and menu can vary, but 4dp is recommended.

_footer: Spacing and interaction on FAB menu for web:  - Enabled  - Hovered  - Selected_
_altText: FAB menu on web states and specifications._

<!-- section: Guidelines -->

_footer: Use the FAB menu to show multiple related actions in a prominent, expressive style_
_altText: On a page of music albums, a FAB menu shows options to make a new playlist, collection, or station._

## Usage

A FAB menu opens from a FAB to show multiple related actions. It should always appear in the same place as the FAB that opened it.

This makes actions immediately accessible, and keeps the UI clean by concealing actions when they’re not needed.

Don’t open a FAB menu from an extended FAB or any other component.

_footer: The FAB menu should always open from a FAB_
_altText: 1 mobile screen with a FAB, 1 with a FAB menu. Both are right aligned._

The FAB menu should be aligned to the trailing edge of the window. 

In right-to-left (RTL) languages, this means the FAB and FAB menu should be aligned to the left edge, and the layout of elements should be mirrored.

_footer: In RTL languages, the FAB menu should be left-aligned with the icon and text placement mirrored_
_altText: 1 mobile screen with a FAB, 1 with a FAB menu. Both are left aligned and mirrored for a right-to-left language._

FAB menus can contain 2–6 items. These should be closely related under a single action, like **Share**. 

Avoid grouping unrelated actions in the same FAB menu.

_footer: FAB menus can have 2-6 items_
_altText: A FAB menu with 5 options on a photo gallery UI._

_footer: Don’t use a FAB menu with one item_
_altText: A FAB menu with 1 option on a photo gallery UI._

When a FAB is paired with other components, like the floating toolbar or navigation rail, don’t use the FAB menu. This prevents cognitive overload and interface clutter.

_footer: FABs can be placed next to toolbars and other components_
_altText: A toolbar with a FAB directly next to it._

_footer: Don't use a FAB menu with a toolbar or navigation rail_
_altText: A toolbar with a FAB menu next to it._

### Color sets

FAB menus have three color sets: primary, secondary, and tertiary. Use the color set that best matches the FAB color style.   

Use the primary FAB menu color set with the **primary** or **primary container** FAB color styles.

_footer: A primary FAB is paired with a primary FAB menu_
_altText: A FAB menu using the primary color set._

Use the secondary FAB menu color set with the **secondary** or **secondary container** FAB color styles.

_footer: A secondary FAB is paired with a secondary FAB menu_
_altText: A FAB menu using the secondary color set._

Use the tertiary FAB menu color set with the **tertiary** or **tertiary container** FAB color styles.

_footer: A tertiary FAB is paired with a tertiary FAB menu_
_altText: A FAB menu using the tertiary color set._

## Anatomy

_footer: - Close button - List item_
_altText: 2 elements of a FAB menu._

FAB menu items should always have label text. The icons shouldn’t be removed since they make each item easy to identify.

_footer: Only remove the icon if necessary. The icon provides a differentiation between items._
_altText: A FAB menu with 3 options for selecting Food, People, or Nature. There are no icons next to the text._

_footer: Don’t remove the label_
_altText: A FAB menu with 3 options for selecting Food, People, or Nature. The options are only icons, no text._

The list item should always hug its contents and look consistent. Avoid truncating text or setting fixed widths. All FAB menu elements should be rounded.

_footer: Keep the padding between the container and icon, icon and text, and text and container consistent_
_altText: A FAB menu used out of the box with no configurations._

_footer: Don’t expand container sizes_
_altText: FAB menu items are equal width despite having different lengths of text._

_footer: Don’t change FAB menu shapes_
_altText: FAB menu items are square instead of round._

## Adaptive layout

The FAB menu can open from any sized FAB. Use with a FAB size suitable for the window size class. For example, larger FABs are recommended for larger windows.

_footer: The FAB menu works in any window size. Pair it with the FAB suitable for that window size._
_altText: The same FAB menu used in medium and compact window sizes._

The FAB menu should remain anchored to the same corner or edge regardless of window size. 

In large and extra large windows, the FAB and FAB menu margins should increase from 16dp to 24dp.

_footer: On desktop, use larger FABs and margins_
_altText: A FAB menu with 24dp margins from the edge of the window._

On web, the FAB menu uses a menu component for an experience that's consistent with other desktop apps.

_footer: The same FAB menu options on both large window (left) and an Android compact window (right)_
_altText: A FAB menu using menu component on web and traditional FAB menu on compact screen._

## Behavior

### Appearing

The FAB should transform into the close button of the FAB menu. The menu items should appear using the [enter and exit](/m3/pages/motion-transitions/transition-patterns#e1c2a650-d7a4-4a6d-9025-e6b7845291ed) transition.

Originate the transition from one of the FAB's trailing corners, preferably the top-aligned corner.

_footer: Animate FAB menus from the top-aligned corner of FABs_
_altText: A FAB transforms into a FAB menu while anchoring the animation to the top right corner of the FAB._

To ensure accessibility for keyboard users on the web, avoid positioning the FAB menu to completely obscure the focus indicator of an actionable element. 

Partially covering the desired element is fine, as long as the focus indicator is visible.

_footer: Ensure the actionable element and its focus indicator are visible behind the FAB menu_
_altText: FAB menu doesn’t obscure actionable element and its focus indicator._

_footer: Don’t block an actionable element and its focus indicator completely with the FAB menu_
_altText: FAB menu obscures both an actionable element and its focus indicator._

### Scrolling

When window height is limited, like when viewing phones in horizontal orientation, FAB menu items can scroll. 

The items should scroll behind the close button.

_footer: FAB menus can scroll if the window height is too short to contain all the options_
_altText: A FAB menu with 6 items scrolls off screen on a horizontal-oriented device. Scrolled items move behind the close button._

### Expanding

Any FAB menu item can expand and adapt to any shape using a [container transform](/m3/pages/motion-transitions/transition-patterns#b67cba74-6240-4663-a423-d537b6d21187) transition pattern. This includes a surface that is part of the app structure, or a surface that spans the entire screen.

_footer: FAB menu items can transition into any kind of shape when selected_
_altText: A FAB menu item expands and transforms into a full screen dialog._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate and interact with the FAB menu
- Ensure focus is correct when navigating through the menu

## Interaction & style

FAB menu elements meet the minimum target size of 48dp.

_footer: FAB menus have 48x48dp minimum width and sufficient spacing by default_
_altText: FAB menu measurement annotations. All elements are larger than the minimum target size._

When the FAB menu can scroll, make sure the items scroll behind the close button. 

The close button should always be easy to access and unobstructed.

_footer: Allow the menu items to scroll behind the close button_
_altText: FAB menu items are scrolling behind the close button._

_footer: Don’t obstruct the close button in short screens like horizontal orientation_
_altText: FAB menu items are scrolling in front of the close button._

## Initial focus

When the FAB is selected, the FAB menu opens, and initial focus remains on the close button, which takes the place of the original FAB.

Then the focus moves from the top menu item to the bottom.

_footer: Focus lands on the close button. People can then navigate through all the items.  - Close button - First menu item - Second menu item - Third menu item_
_altText: 4 FAB menus with the focus order labelled. Focus moves from the close button at the bottom to the topmost menu item next._

## Keyboard navigation

**Keys**
 |
**Actions**
 |

**Tab**
 |
Navigate to the next interactive element
 |

**Space** or **Enter**
 |
Activate the focused button or item
 |

## Labeling elements

### Android

On Android, a FAB menu’s close button should include a state to tell screen readers what action will occur when it's toggled. The close button should be labeled: 

-
Label: Toggle menu

-
Role: Button

-
State: Expanded or collapsed

_footer: On Android, the **close button** accessibility labels should include a toggle menu label, button role, and an expanded or collapsed state_
_altText: Accessibility labels for the close button on an Android device._

FAB menu items should be labeled:

-
Label: Match the item’s UI text, such as **Reply all**

-
Role: Button

_footer: Label FAB menu items to match their UI text, like **Reply all**, and use the button role_
_altText: Accessibility labels for a FAB menu item on an Android device._

### Web

On web, a FAB menu is a combination of a FAB and a menu component. The FAB opens the menu. Follow the [accessibility guidelines for FABs](/m3/pages/fab/accessibility) and [menus](/m3/pages/menus/accessibility).

The FAB's accessibility label should describe the menu that the FAB will open.
