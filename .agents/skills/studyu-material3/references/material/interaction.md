# Material 3 · Interaction

<!-- Source: m3.material.io · foundations_interaction_states · updated 2026-07-17T05:30:22.307Z · CC-BY 4.0 (Google) -->

## States

> States show the interaction status of a component or UI element



<!-- section: Overview -->

- States have two visual indicators to ensure accessibility
- States can be combined, such as selection and hover
- Apply states consistently across components

## Resources

Type | Link | Status |
Design | [Design Kit](http://goo.gle/m3-design-kit) | Available |

1. [Enabled](/m3/pages/interaction-states/applying-states#39b2fc90-01db-41b5-b6f8-47be61ed1479)An enabled state communicates an interactive component or element.

2. [Disabled](/m3/pages/interaction-states/applying-states#4aff9c51-d20f-4580-a510-862d2e25e931)
A disabled state communicates an inoperable component or element.

_footer: Enabled button_
_altText: Enabled button has a strong contrast between container and text._

_footer: Disabled button_
_altText: Disabled button has low contrast grey text on grey container._

3. [Hover](/m3/pages/interaction-states/applying-states#71c347c2-dd75-485b-892e-04d2900bd844)
A hover state communicates when a user has placed a cursor above an interactive element.

4. [Focused](/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f)
A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice.

_footer: Hovered button_
_altText: Cursor positioned over a button._

_footer: Focused button_
_altText: The focused button has a strong contrast between container and text._

5. [Pressed](/m3/pages/interaction-states/applying-states#c3690714-b741-492d-97b0-5fc1960e43e6)
A pressed state communicates a user tap.

6. [Dragged](/m3/pages/interaction-states/applying-states#c97582c4-5fef-42ce-9c34-71f8dcc5b8ad)
A dragged state communicates when a user presses and moves an element.

_footer: Pressed button_
_altText: The pressed button has a strong contrast between container and text._

_footer: Dragged chip_

<!-- section: State layers -->

## State layers

A state layer is a semi-transparent covering on an element that indicates its state. State layers provide a systematic approach to visualizing states by using opacity. A layer can be applied to an entire element or in a circular shape and only one state layer can be applied at a given time.

To transition from an enabled style to a stateful style requires the addition of a state layer.

The state layer is an overlay with a fixed opacity for each state and uses the same color as the content. 

For example, if the enabled style uses the **secondary container** color for the container and **on secondary container** for content, the state layer will be an overlay using the **on secondary container** color.  

If the enabled style uses the **surface** color for the container and the **primary** color role for content, then the state layer will be an overlay using the **primary** color.

_footer: - Container - State layer - Content_
_altText: State layer sandwiched between the container and content._

The size of state layers is 40dp while the interactive target size is 48dp.

_footer: - State layer - Interactive target_
_altText: Interaction target is larger than the state layer._

### On colors

By default, a component’s state layer color is derived from the color of its content, either the color of an icon or label text if no icon is present.

An [on color](/m3/pages/color-roles#19e75989-7485-4f5b-a769-940c4e4364bc) is a color role used by the content. Each container color has its own corresponding on color. For example, if a container color is **secondary container**, the content will use the **on secondary container** color role.

_footer: Order of surface layers shows the state layer (2) between the container (1) and content (3) layers_
_altText: State layer sandwiched between  the content and container._

### State layer tokens & values

The state layer uses a fixed percentage for the opacity for each state. A state layer uses the color used by content (usually the [on color](/m3/pages/color-roles#19e75989-7485-4f5b-a769-940c4e4364bc)) and the percentage opacity for its respective state.

_footer: Four overlay states and their values:  - Hover +8% opacity - Focus +10% opacity - Press +10% opacity - Drag +16% opacity_
_altText: The opacity values of four overlay states._

<!-- section: Applying states -->

## Enabled

An enabled state communicates an interactive component or element. Enabled states use the default styling for each interactive component.

_footer: Enabled states for:  - Button - FAB - Switch - Text field_
_altText: Enabled state of 4 components._

## Disabled

A disabled state communicates when a component or element isn’t interactive. This state is visually communicated through color changes and reduced elevation.

**Disabled states don't need to meet Material's contrast requirements.**

_footer: Disabled button_
_altText: Low opacity solitary button labeled disabled, indicates a  disabled/inoperable state._

Disabled states **are** inherited by action, selection, and input components:

- Buttons
- Cards
- Checkboxes
- Chips
- List items
- Radio buttons
- Switches
- Text fields

_footer: Disabled states for:  - Checkbox - Icon button - Radio button - Segmented button_
_altText: Inoperable state of 4 components._

Disabled states **aren't** inherited by communication, containment, navigation, and some actions components: 

- App bars
- Badges
- Dialogs
- Floating action buttons (FABs)
- Menus
- Navigation bar, drawer, and rail
- Sheets
- Tabs
- Tooltips

_footer: If the action represented in the FAB is unavailable, the FAB shouldn't appear_
_altText: Screen erroneously showing edit FAB in inoperable state, though the edit function is unavailable._

### Behavior

Disabled components can’t be focused, dragged, or pressed, and they don’t change state when tapped or hovered over.

_footer: A disabled button doesn’t inherit hover or other state layers_
_altText: A cursor moves over and clicks on an disabled/inoperable button and the button doesn’t change._

There can be any number of disabled states in a layout.

_footer: - Disabled redo icon button - Disabled checklist icon button_
_altText: Disabled components on a screen._

## Hover

Hover states are initiated by the user pausing over an interactive element using a cursor.

The lower-emphasis surface overlay for hover states can be applied to the entire component, elements within a component, or as a circular shape over part of the component.

_footer: Hovered button_
_altText: Cursor moves toward button which reads “enabled” and when the cursor touches the button text changes to “hovered.”_

Hover states **are** inherited by action, selection, and input components:

- Buttons
- Cards
- Checkbox
- Chips
- Date and time pickers
- List items
- Slider
- Switch
- Text fields

_footer: Hovered states for:  - FAB - Icon button - Chip - Segmented buttons_
_altText: Hover state of 4 components._

Hover states **aren’t** inherited by communication, containment, or navigation components: 

- App bars
- Badges
- Dialogs
- Menus
- Navigation bar, drawer, and rail
- Sheets
- Tabs

_footer: The individual components that are actionable within the app bar inherit hover states, not the whole app bar_
_altText: Mobile screen with the whole  app bar wrongly in hover state._

### Behavior

Hover states are initiated by the user pausing over an interactive element using a cursor.

_footer: Hover states appear and disappear using a low-emphasis animated fade_
_altText: Button’s text“Enabled”  changes to“Hovered” when cursor moves over the button._

Hover states can be combined with focused, activated, selected, or pressed states.

_footer: A selected filter chip in both selected and hover states_
_altText: Filter chip text matches state as it's unselected, hovered, and selected by a cursor._

There can only be one hover state at a time in a layout.

_footer: Hover state can only be on one element at a time based on cursor position_
_altText: Hover state moves from one card to another with cursor movement._

## Focused

A focused state communicates when a user has highlighted an element using a keyboard or voice. Focus states apply to all interactive components.

The higher-emphasis surface overlay for focused states can be applied to the entire component, elements within a component, or as a circular shape over part of the component.

_footer: Focused button_
_altText: A button in focused state._

Focus states **are** inherited by action, selection, and input components:

- Buttons
- Cards
- Checkbox
- Chips
- Date and time pickers
- List items
- Selection controls
- Text fields

_footer: Focused states for:  - FAB - Icon button - Chip - Segmented buttons_
_altText: Focus state of 4 components._

Focus states **aren’t** inherited by most communication, containment, or navigation components:

- App bars
- Badges
- Banner
- Card
- Dialogs
- Navigation bar, drawer, and rail
- Sheets

_footer: The individual components that are actionable within the app bar inherit focus states, not the whole app bar_
_altText: Mobile screen showing  entire app bar in focus state, which is an error._

### Keyboard focus indicator

Many people use the **Tab** key or other shortcut to navigate the interactive elements of a web page, like links, buttons, and chips.

When an element is tabbed to, it appears in its focused state with a ring-like **keyboard focus indicator**. This indicator helps web users know where they are on the page.

While focused, an element can be acted on with the keyboard.

_footer: Keyboard focus indicator for a filled button_
_altText: A single filled button in focused state, displaying the keyboard focus indicator._

### Behavior

Focus states are initiated by the user by pressing the **Tab**key on the keyboard (or equivalent).

Focus states can be represented in combination with hover, activated, or selected states.

_footer: A selected filter chip in both selected and focused states_
_altText: A single filter chip simultaneously in selected state and focus state._

There can only be one focus state at a time in a layout.

_footer: A focus state applied to one card at a time_
_altText: Cursor moving from one card in focus state to another card moves the focus state to the second card._

## Pressed

A pressed state communicates a user-initiated tap or click via cursor, keyboard, or voice input. This state applies to all interactive components.

Pressed states trigger a change in composition and should be high-emphasis.

A ripple overlay signifies a pressed state. It can be applied to an entire component or elements within a component, or as a circular shape over part of the component.

_footer: Pressed button_
_altText: Button using a ripple overlay to signify it’s in a pressed state._

Some components, such as buttons or cards, can inherit elevation to signify a pressed state.

_footer: Pressed button with elevation_
_altText: Button using elevation to signify it’s in a pressed state._

Pressed states **are** inherited by action, selection, and some containment components: 

- Buttons
- Cards
- Checkbox
- Chips
- List items
- Text fields

_footer: Pressed states for:  - FAB - Icon button - Chip - Segmented button_
_altText: Four components shown in pressed state._

Pressed states **aren’t** inherited by communication, navigation, or some containment components: 

- App bars
- Badges
- Bottom navigation
- Dialogs
- Menus
- Sheets
- Tabs

_footer: The individual components that are actionable within the app bar inherit pressed states, not the whole app bar_
_altText: Mobile screen showing  entire app bar in pressed state is an error._

### Behavior

Pressed states are initiated by user keyboard or voice input on an interactive element.

_footer: Activated states appear in user-initiated order_
_altText: Enabled state activated to pressed state._

Pressed states can be combined with hovered, focused, activated, or selected states.

_footer: Activated states can be represented in combination with hover and focus_
_altText: Hovered state activated to a pressed state._

There may only be a single pressed state at a time in a layout.

_footer: A pressed state applied to one card at a time_
_altText: Pressed state on one card at a time._

## Dragged

A dragged state occurs when a user presses and moves an element or component. Dragged states should be low emphasis, to avoid distracting users from their task.

Dragged states use a lower emphasis overlay. It can be applied to the entire component or to elements within a component.

Some components, such as list items, chips, or cards, can inherit elevation to signify a dragged state.

_footer: Dragged list item_
_altText: List item shown in dragged state._

Dragged states **are** inherited by some containment and selection components: 

- Cards
- Chips
- List items
- Sliders

_footer: Dragged states for:  - Chip - Card_
_altText: A chip and a card both shown in dragged state._

Dragged states **aren’t** inherited by action, communication, navigation, or some containment components: 

- App bars
- Badges
- Buttons
- Dialogs
- Menus
- Navigation bar, drawer, and rail

_footer: Components like an app bar that require consistent placement should not inherit dragged states_
_altText: Mobile screen with app bar in dragged state is an error._

### Behavior

Dragged states are initiated when users touch and hold elements, using an input method such as a tap or click.

_footer: A list item in a dragged state_
_altText: Going through the states of a draggable list item:  enabled, hovered, dragged._

There may only be a single dragged state at a time within a layout.

_footer: Dragged state applied to one card at a time_
_altText: Cursor dragging cards one at a time._

---

<!-- Source: m3.material.io · foundations_interaction_gestures · updated 2026-07-17T05:06:24.826Z · CC-BY 4.0 (Google) -->

## Gestures

> Gestures are all the ways people interact with UI elements using touch



<!-- section: Tab 1 -->

-
Gestures help people navigate, take action, or transform content

-
UI elements should respond to gestures in real time

-
Tap, scroll, and swipe are common gestures

## Resources

Type
 |
Link
 |
Status
 |

Design
 |
[Design Kit (Figma)](http://goo.gle/m3-design-kit)
 |
Available
 |

## Types of gestures

### Tap

People can navigate to destinations and interact with elements through touch.

_footer: Tapping a card opens an article_
_altText: Mobile UI shows a tap on the 1st of 3 news cards. The card opens to show the full article._

### Double tap

Two quick taps allows people to zoom in and out of content.

_footer: Double tapping on a photo opens it to full screen_
_altText: Mobile UI shows a double tap on a floral photo. The image expands to fill the screen._

### Long press

People can access additional functionality by pressing on elements for an extended time.

_footer: Long pressing a list item selects it_
_altText: A long press on an email reveals a selection checkmark and a container color change._

### Scroll and pan

People can slide surfaces vertically, horizontally, or in any direction to move through content.

_footer: Vertical scrolling reveals more content_
_altText: Scrolling a feed.Scrolling up and down in a photo feed._

### Swipe

People can navigate horizontally to:

-
Switch between peer views like tabs

-
Complete actions

_footer: Swiping a list item can reveal additional actions_
_altText: A swipe right on an email reveals a favorites icon._

### Predictive back

On Android, a person can swipe left or right on certain components as a way to navigate to a previous destination. This gesture is called [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md).

Before completing the swipe, the person can decide to continue to the previous view or stay in the current view.

Compatible components are:

-
Bottom sheet

-
Navigation bar

-
Navigation rail

-
Search bar

-
Side sheet

_footer: A predictive back swipe on a bottom sheet goes back to the previous screen_
_altText: Back swipe on a bottom sheet takes s person back to the previous screen of a photo feed._

### Drag

People can move elements around and slide surfaces in and out of view.

_footer: A list can be reordered by dragging a list item_
_altText: A person drags the second email in a mobile inbox to the third position and back to the second position._

### Pick up and move

A long press and drag allows people to reorder content.

_footer: A calendar event can be picked up and moved to a new time_
_altText: Picking up and moving a calendar event to a new time._

### Pinch

People can scale surfaces to navigate between screens.

_footer: A photo can be pinched outward to a full screen view_
_altText: Dragging two points apart opens photo to full screen, dragging them towards each other collapses the photo._

### Compound gestures

Users can fluidly transition between various gestures, like panning and pinching in a map view.

_footer: A map UI can be navigated through a combination of pan and pinch_
_altText: Pan gesture moves map, then pinch gesture is used to zoom out then in._

---

<!-- Source: m3.material.io · foundations_interaction_inputs · updated 2026-07-17T05:07:20.540Z · CC-BY 4.0 (Google) -->

## Inputs

> Inputs are devices that provide interactive control of an app. Common inputs include a mouse, keyboard, or touchpad.



<!-- section: Tab 1 -->

- Design for touch, keyboard, and mouse interactions
- Embrace multiple input methods and gestures within your app

_footer: Designing for inputs allows people to use the inputs they prefer, like a mouse to highlight text on a tablet_
_altText: Editing interface on a large screen device. The selected text is highlighted and the text cursor is visible._

## External inputs for devices

People can use external inputs like a mouse, keyboard, or stylus with their phone, tablet, foldable, TV, laptop, or desktop computer. When someone connects an external input to their device, they expect it to behave in familiar and useful ways. Designing for different input methods can make a product more usable and accessible on all screen sizes.

### Common features of external inputs

#### **Mouse**

- Left and right click
- Mouse wheel
- Extra buttons

#### **Trackpad**

- Left and right click
- Gestures
- Haptics

#### **Physical keyboard**

- Replaces virtual keyboard
- Media keys
- Modifier keys

_altText: Image of a mouse._

_altText: Image of a laptop keyboard and trackpad._

_altText: Image of a keyboard._

### Input device behaviors

Depending on the input device, designers and developers can implement behaviors that meet standard conventions and user expectations.
Input device action | Anticipated behavior |
Mouse and trackpad movement
 | Show a mouse cursor on the screen |
Primary click
 | Treat mouse clicks differently than touch events |
Secondary click
 | Activate context menus |
Hover
 | Change component states |
Highlight | Allow text to be selected by the mouse cursor |
Mouse wheel and trackpad two finger drag | Scroll list vertically and horizontally |
Trackpad pinch
 | Zoom an element or page |
Physical keyboard
 | Hide and show on screen keyboard |

## Mouse and cursor interactions

When an external mouse input device is used, a mouse cursor should be shown, regardless of the device type. 

A mouse may be connected to tablets, laptops, phones, foldables, and more. On some devices, it's possible to use an external input device simultaneously with touch input. 

On devices that don't specifically recognize mouse or stylus input, the mouse is treated as touch input.

### Primary click

A mouse click or stylus tap should demonstrate the same feedback as touch input. One example of this is showing the ripple for a pressed state.

_footer: A visible mouse cursor is seen when the external input is connected_
_altText: A view of a display with a visible mouse cursor._

### Secondary click

#### Context menus

A secondary click (whether using a single button or two fingers on a trackpad) should activate a context menu. The context menu shows additional options for the object that's clicked. See [menus](/m3/pages/menus/overview) for more usage and guidelines.

_footer: The context menu should appear when right clicking with a mouse or trackpad_
_altText: A context menu pop up from a link with the options: Open link in new window, Save link as, Copy link location, and Inspect._

### Hover

When using a mouse cursor, help users discover interactive objects by enabling visual changes. When the mouse rests on an interactive element, the hover state is a valuable cue for interaction. See [states](/m3/pages/interaction-states/applying-states#71c347c2-dd75-485b-892e-04d2900bd844) for styles and guidelines.

Hovering with a cursor (or stylus) should also invoke tooltips when applicable. See [tooltips](/m3/pages/tooltips/overview) for guidance.

_footer: - Components without a hover state - Components with a hover state change applied_
_altText: Icon button, floating action button, and menu items in their hovered and not hovered states._

### Cursors

Cursors appear when using external input devices like a mouse or trackpad. The cursor can change to communicate more information about interactive elements.

#### Pointer

By default, external input control should be rendered as a pointer.

_footer: - A pointer provides a visible indicator for input controls_
_altText: A cursor rendered as a pointer._

#### Hand

The cursor should appear as a hand to indicate links or linked images.

_footer: - The hand cursor is used for links and clickable images_
_altText: A link cursor (hand) shown when hovering over a linked image._

#### Resize arrows

The cursor should change to resize arrows on the boundaries of resizable elements.

_footer: - Resize arrows indicate an element can be resized_
_altText: A cursor at the edge of the screen as resize arrows._

#### I-beam

The cursor should appear as an I-beam when hovering on text. When manipulating editable text, the following interactions apply:

- Single click places the cursor
- Double click selects a word
- Triple click selects a paragraph
- Single click deselects text and repositions the cursor

_footer: - An I-beam cursor indicates selectable text_
_altText: I-beam cursor hovering over selectable text._

### Text selection

When selecting text using a mouse, trackpad, or stylus:

- Highlight the selected area using a single color
- Don’t show touch controls next to the highlighted area

_footer: - Selected text shows a visible highlight_
_altText: Highlighted text in a single color._

### Text selection with touch control

When interacting using touch, always show touch controls, even if other inputs are connected.

When using a mouse, trackpad, or stylus, show the I-beam and context menu, even if it's a touch device.

_footer: When using a touchscreen to select text, show touch controls_
_altText: Touch controls are produced on selected text, with mouse and trackpad detected._

_footer: When using a mouse, trackpad, or stylus to select text, use the right-click context menu_
_altText: Selected text with a context menu, with mouse and trackpad detected._

### Stylus input

When using a stylus, cursors are usually not necessary, unless they communicate tool properties such as brush size or shape.

_footer: - The circle cursor indicates the selected stylus tool and size_
_altText: A cursor rendered as a circle._

## Mouse wheel and trackpad gestures

When an external mouse or touchpad is used, the mouse wheel and trackpad gesture allow more actions.

### Vertical scroll

When a cursor is positioned on a list, the mouse wheel and two-finger touchpad gesture should allow vertical scrolling of the list.

_footer: Scrolling a vertical list using the mouse wheel or trackpad gestures. Note that only the detail panel under the cursor scrolls._
_altText: Stationary cursor over a scrolling field controlled by a mouse wheel or trackpad._

### Touch scroll & mouse text selection

Upon touch and drag gesture, the text area will scroll. With a mouse interaction, dragging in a text area will select the text.

_footer: On a touch screen, dragging upward scrolls the field down_
_altText: Animation of a swipe gesture to scroll the screen._

_footer: When using a mouse, dragging upward selects text and images_
_altText: Animation showing a dragging gesture with a mouse to select text and image._

### Horizontal scroll

Mouse users should be able to scroll with a mouse wheel to navigate horizontally scrolling fields. Trackpad users should be able to scroll using a two-finger horizontal gesture.

_footer: Carousels can scroll horizontally using a scroll wheel or trackpad_
_altText: A news feed of horizontally scrolling cards._

## Physical keyboard

When a physical keyboard is connected to a device, either externally or as a built-in laptop keyboard, users should be able to perform any actions that the virtual keyboard provides, and more.

### Show and hide virtual keyboard

A virtual keyboard should appear or hide in response to the presence of a physical keyboard.

_footer: When a physical keyboard is attached, hide the virtual keyboard_
_altText: Text being entered into a field with no on-screen keyboard displayed._

_footer: When a physical keyboard is removed, show the virtual keyboard_
_altText: Text being entered into a field with an on-screen keyboard._

### Common keyboard interactions

#### Enter key

People typically expect the **E****nter** key on a physical keyboard to be enabled by developers to allow a common function like sending a message.

_footer: The**Enter**key typically triggers actions like sending a message_
_altText: A message being typed into a chat, and sent using the Enter key._

#### Spacebar control

People typically expect the **Spacebar** (or available media keys) to be enabled to play and pause music or video.

_footer: Pressing **Space** usually pauses and plays media_
_altText: A video being paused and resumed by pressing the Spacebar._

#### Tab focus

When keyboard users navigate a page using **Tab**, the focus on interactive items must follow a logical order. On most pages, that means left to right, top to bottom.

When focused from a keyboard or other input device, the focus state includes a ring-like keyboard focus indicator.

_footer: Tab focus includes a visible keyboard focus indicator_
_altText: Tab focus is on “small,” which is one of four size options for sweatshirts at an online store._

_footer: The focus state moves elements as the user presses **Tab** on their keyboard_
_altText: Tab focus is on “medium,” which is one of four size options for sweatshirts at an online store._

#### Escape key

People typically expect the **Escape** key on a physical keyboard to dismiss elements, remove focus, or clear selections.

_footer: The **Escape** key should dismiss any visible modal elements like menus, dialogs, or bottom sheets_
_altText: Escape key dismisses menu._

_footer: The **Escape** key should remove any visible focus indicators and set the focus order to 0_
_altText: Escape key removes focus indicator from icon._

_footer: The **Escape** key should remove the text cursor when typing, but should not remove already-typed text_
_altText: Escape key dismisses text cursor and leaves text itself unchanged._

---

<!-- Source: m3.material.io · foundations_interaction_selection · updated 2026-07-17T05:28:53.854Z · CC-BY 4.0 (Google) -->

## Selection

> Selection is how people interact with UI elements or choose which items to act on



<!-- section: Tab 1 -->

- Selection is shown through changes to surface color or other visible elements
- An entire component can be selected, or just certain parts in a component
- Selection can be performed via tap, cursor, keyboard, or voice

## Resources

Type | Link | Status |
Design | [Design Kit (Figma)](http://goo.gle/m3-design-kit) | Available |

## Selection indicators

Selections are displayed using a check mark icon, a checkbox component, a change in surface color, or a combination.

Selections are inherited by the following components: 

- Cards
- Checkboxes
- Chips
- Data tables
- Icon buttons
- List items
- Menu items
- Pickers
- Radio buttons
- Segmented buttons
- Sliders
- Switch

_footer: Selected components:  - Segmented buttons - Chips - List items - Checkboxes - Radio buttons - Switch - Slider_
_altText: Seven types of selected  components._

The following components use an active indicator to represent which item is currently selected:

- Navigation bar
- Navigation drawer
- Navigation rail
- Tabs

The color and shape of the active indicator varies between components. In these components, only one item should be selected at a time.

_footer: Selected components with active indicators:  - Tab - Navigation drawer_
_altText: Tabs and navigation drawer with one destination item selected. Selection is identified with an active indicator._

## Types of selection

### Touch

On touch devices, select items using:

- Long press touch or two-finger touch
- Selection shortcut, if available, such as tapping an avatar

_footer: Items in a list selected via touch_
_altText: Touch used to select 3 list items one after another._

### Entering and exiting selection mode

To select an item and enter selection mode, long press the item or use a shortcut, such as tapping the item’s avatar. To select additional items, tap each of them.

To exit a selection mode, tap each selected item until they’re unselected, or tap an action on the toolbar.

_footer: Entering and exiting selection mode_
_altText: List items are tapped to select and unselect them._

### Larger selections

To select multiple items simultaneously, long press and drag across items. Don’t use this gesture combination if it is already in use to pick up and move items, like cards.

_footer: **Long press** and **drag** can be used together to select items in batches_
_altText: Long press and drag used to select multiple images in a photo feed._

_footer: If the **long press** and **drag** combination is already in use to pick up and move components, like cards, then the combined gesture can’t also be used for selecting items in batches_
_altText: Long press and drag combination used to move cards, but can’t be used to batch select items while in use._

### Click

On desktop, checkboxes are always visible when selection is the primary activity. When selection is secondary, checkboxes (or other indicators) are displayed:

- As a single checkbox for that item on hover
- For all items after one item is selected

To make a selection, hover over an item to reveal a checkbox. The checkbox can then be clicked.

_footer: Checkboxes are visible by default in this table because selection is a primary activity_
_altText: Checkboxes being selected and unselected._
