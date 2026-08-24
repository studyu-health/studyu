# Material 3 · Input

<!-- Source: m3.material.io · components_text-fields · updated 2026-07-30T05:18:12.451Z · CC-BY 4.0 (Google) -->

## Text fields



<!-- section: Overview -->

-
Make sure text fields look interactive

-
Two variants: filled and outlined

-
The text field’s state (blank, with input, error, etc) should be visible at a glance

-
Keep labels and error messages brief and easy to act on

-
Text fields commonly appear in forms and dialogs

_footer: - Filled text field - Outlined text field_
_altText: 2 variants of text fields, filled and outlined._

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color

_footer: Text fields have new color mappings_
_altText: A filled and outlined text field with M3 color mappings._

<!-- section: Specs -->

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](/m3/pages/design-tokens/overview)

## Filled text field

_footer: - Container  - Leading icon (optional)  - Label text in empty field  - Label text in populated field  - Trailing icon (optional)  - Focused active Indicator  - Caret  - Input text  - Supporting text (optional)  - Enabled active indicator_
_altText: Diagram of a filled text field indicating the 10 parts of its anatomy._

### Filled text field color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Filled text field color roles used for light and dark schemes:  - Surface container highest  - On surface variant  - On surface variant  - Primary  - On surface variant  - Primary  - Primary  - On surface  - On surface variant  - On surface_
_altText: Diagram of a filled text field indicating its color mappings._

### Filled text field states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: - Enabled (empty) - Focused (empty) - Hovered (empty) - Disabled (empty) - Enabled (populated) - Focused (populated) - Hovered (populated) - Disabled (populated)_
_altText: Side by side view of empty and populated filled text fields across different states, showing the differences between enabled, focused, hovered, and disabled._

### Filled text field error states

Error states are visual representations used to communicate the status of a component or interactive element. An error message can display instructions on how to fix it. Error messages are displayed below the text field as supporting text until fixed.

_footer: - Enabled (empty) - Focused (empty) - Hovered (empty) - Enabled (populated) - Focused (populated) - Hovered (populated)_
_altText: Side by side view of empty and populated filled text fields across different error states, showing the differences between enabled, focused, hovered._

### Filled text field measurements

_footer: Padding and size measurements without icons_
_altText: Diagram showing layout values and paddings for filled text fields without icons._

_footer: Padding and size measurements with icons_
_altText: Diagram showing layout values and paddings for outlined text fields with leading and trailing icons._

_footer: Padding and size measurements with supporting text and character count_
_altText: A diagram showing layout values and paddings for supporting text, and supporting text in combination with a character count._

Attribute | Value |
Default container height
 | 56dp |
Label alignment (unpopulated)
 | Vertically centered |
Top/bottom padding
 | 8dp |
Left/right padding without icons
 | 16dp |
Left/right padding with icons
 | 12dp |
Icon alignment
 | Vertically centered |
Padding between icons and text
 | 16dp |
Supporting text and character counter top padding
 | 4dp |
Padding between supporting text and character counter
 | 16dp |
Target size | 56dp |

### Filled text field configurations

_footer: Empty and populated filled text fields with:  - Supporting text  - Trailing icon  - Leading icon  - Leading and trailing icons  - Prefix  - Suffix  - Multi-line text field_
_altText: Side by side view of filled text fields in different configurations._

## Outlined text field

_footer: - Enabled container outline  - Leading icon (optional)  - Label text in empty field  - Label text in populated field  - Trailing icon (optional)  - Focused container outline  - Caret  - Input text  - Supporting text (optional)_
_altText: Diagram of an outlined text field indicating the 9 parts of its anatomy_

### Outlined text field color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Outlined text field color roles used for light and dark schemes:  - Outline - On surface variant - On surface variant - Primary - On surface variant - Primary - Primary - On surface - On surface variant_
_altText: Diagram of an outlined text field indicating its color mappings_

### Outlined text field states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: - Enabled (empty) - Focused (empty) - Hovered (empty) - Disabled (empty) - Enabled (populated) - Focused (populated) - Hovered (populated) - Disabled (populated)_
_altText: Side by side view of empty and populated outlined text fields across different states, showing the differences between enabled, focused, hovered, and disabled._

### Outlined text field error states

Error states are visual representations used to communicate the status of a component or interactive element. An error message can display instructions on how to fix it. Error messages are displayed below the text field as supporting text until fixed.

_footer: - Enabled (empty) - Focused (empty) - Hovered (empty) - Enabled (populated) - Focused (populated) - Hovered (populated)_
_altText: Side by side view of empty and populated filled text fields across different error states, showing the differences between enabled, focused, hovered._

### Outlined text field measurements

_footer: Padding and size measurements without icons_
_altText: A diagram showing layout values and paddings for outlined text fields without icons._

_footer: Padding and size measurements with icons_
_altText: A diagram showing layout values and paddings for outlined text fields with leading and trailing icons._

_footer: Padding and size measurements with supporting text and character count_
_altText: A diagram showing layout values and paddings for supporting text, and supporting text in combination with a character count._

Attribute | Value |
Container height
 | 56dp |
Left/right padding without icons
 | 16dp |
Left/right padding with icons
 | 12dp |
Padding between icons and text
 | 16dp |
Icon alignment
 | Vertically centered |
Supporting text and character counter top padding
 | 4dp |
Padding between supporting text and character counter
 | 16dp |
Label alignment
 | Vertically centered |
Left/right padding populated label text
 | 4dp |
Target size | 56dp |

### Outlined text field configurations

_footer: Empty and populated outlined text fields with:  - Supporting text  - Trailing icon  - Leading icon  - Leading and trailing icons  - Prefix  - Suffix  - Multi-line text field_
_altText: A side by side view of outlined text fields in different configurations._

<!-- section: Guidelines -->

_footer: Filled and outlined text fields_
_altText: A side by side view of a filled and a outlined text field._

## Usage

Use a text field when someone needs to enter text into a UI, such as filling in contact or payment information.

_footer: Contact form using outlined text fields_
_altText: Mobile UI of contact form with several text fields._

There are two variants of text fields:

-
Filled text fields

-
Outlined text fields

Both variants of text fields use a container to provide a visual cue for interaction and provide the same functionality.

_footer: Filled text field_
_altText: Side by side view of a populated and unpopulated filled text field._

_footer: Outlined text field_
_altText: Side by side view of a populated and unpopulated outlined text field._

### Outlined text fields

Outlined text fields have less visual emphasis than filled text fields. When they appear in places like forms (where many text fields are placed together), their reduced emphasis helps simplify the layout.

_footer: Login screen with outlined text fields_
_altText: App screen with 1 focused and 1 unfocused outlined text field._

## Choosing text fields

### Choosing text fields

Both variants of text field provide the same functionality. The variant of text field used can depend on style alone.

Choose the variant that:

-
Works best with an app’s visual style

-
Best accommodates the UI's goals

-
Is most distinct from other components (like buttons) and surrounding content

_footer: Mobile form using filled text fields_
_altText: Mobile UI of a contact form with several filled text fields._

_footer: The same mobile form using outlined text fields_
_altText: Mobile UI of a contact form with several outlined text fields._

### Using both text field variants on the same screen

If both variants of text field are used in a UI, they should be used consistently within different sections, and not intermixed within the same region. 

For example, use outlined text fields in one section and filled text fields in another.

_footer: When using both variants of text fields in a UI, separate them by region_
_altText: Mobile UI of a contact form with several filled text fields, and an open dialog on top using an outlined text field._

_footer: When using both variants of text fields, don't use both next to each other or within the same form_
_altText: Mobile UI of a contact form with a mix of outlined and filled text fields._

## Anatomy

### Filled text field

_footer: - Container  - Leading icon (optional)  - Label text in empty field  - Label text in populated field  - Trailing icon (optional)  - Focused active Indicator  - Caret  - Input text  - Supporting text (optional)  - Enabled active Indicator_
_altText: Diagram of filled text field indicating the 10 parts of its anatomy._

### Outlined text field

_footer: - Enabled container outline  - Label text in empty field  - Leading icon (optional)  - Label text in populated field  - Trailing icon (optional)  - Focused container outline  - Caret  - Input text  - Supporting text (optional)_
_altText: Diagram of an outlined text field indicating the 9 parts of its anatomy._

### Containers

Containers improve the discoverability of text fields by creating contrast between the text field and surrounding content.

**Fill and stroke**
A text field container has a fill and a stroke either around the entire container, or just the bottom edge. The color and thickness of a stroke can change to indicate when the text field is active. 

**Rounded corners**
The container of an outlined text field has rounded corners, while the container of a filled text field has rounded top corners and square bottom corners.

_footer: Text field containers_
_altText: Side by side view of the containers of a filled and outlined text field._

### Label text

Label text tells people what information is requested. Every text field should have a label.

Label text should be aligned with the input text, and always visible. It can be placed in the middle of a text field, or rest near the top of the container.

Label text shouldn't be truncated or take up multiple lines. Keep it short, clear, and fully visible.

_footer: Label text should always be visible. When the field is selected, the label text moves from the middle of the text field to the top._
_altText: Animation of 2 text field’s label text changing position when empty and populated._

_footer: Don’t truncate label text. Keep it short, clear, and fully visible._
_altText: Text field with very long label text, too long to display fully display inside the text field container._

_footer: Label text shouldn’t take up multiple lines_
_altText: Text field with very long label text split into 2 lines._

### Adjacent label

A text field doesn't require a label if the field's purpose is indicated by a separate, adjacent label. 

Adjacent labels should be aligned to the leading edge of the text field container.

_footer: Text fields with adjacent labels_
_altText: Mobile UI of a contact form with label texts placed outside and on top of the text fields._

### Required text indicator

To show a field is required, display an asterisk (*) next to the label text, and explain that asterisks indicate required fields in one of two ways:

- Supporting text
- A single note at the beginning of the form

Additional best practices include:

- Indicate all required fields
- If required text has a particular color, use the same color for the asterisk

_footer: Asterisk with required supporting text_
_altText: Mobile UI of a contact form showing supporting text below the text field, indicating an input is required._

### Input text

Input text is text a person has entered into a text field.

Text fields can display input text in the following ways:

- **Single line** text fields display only one line of text
- **Multi-line** text fields grow to accommodate multiple lines of text
- **Text areas** are fixed-height fields

_footer: Input text in a filled text field_
_altText: Text field with populated input text._

_footer: In **single-line** fields, as the cursor reaches the right field edge, text longer than the input line automatically scrolls left. Single-line fields are not suitable for collecting long responses; use a multi-line text field or text area instead._
_altText: Text field with very long input text that scrolls sideways._

_footer: In **multi-line** fields, overflow text causes the text field to expand, shifting screen elements downward and text wraps onto a new line. These fields initially appear as single-line fields, which is useful for compact layouts that need to accommodate large amounts of text._
_altText: Text field with very long input text that wraps into a second line, expanding the text field container._

_footer: **Text areas** are taller than text fields and wrap overflow text onto a new line. They are a fixed height and scroll vertically when the cursor reaches the bottom of the field. The large initial size indicates that longer responses are possible and encouraged. These should be used instead of multi-line fields on the web. Ensure the height of a text area fits within mobile screen sizes._
_altText: Text area with enough space to allow a very long input text to wrap into a second line without the need to expand the container._

### Prefix text

Text fields can contain prefix text such as currency symbol.

_footer: A text field with a currency symbol text prefix_
_altText: Text field with a currency prefix before the input text._

### Suffix text

Text fields can contain suffix text such as unit of measurement or email domain.

_footer: A text field with a grading scale as suffix_
_altText: Text field with a suffix after the input text indicating a maximum input of 100._

_footer: A text field with an email domain suffix_
_altText: Text field with a suffix after the input text indicating an email address._

### Supporting text & character counter

Supporting text conveys additional information about the input field, such as how it will be used. It should ideally be one line, though may wrap to multiple lines if required. It can be either persistently visible or visible only on focus.

If there is a character or word limit, include a character or word counter. They display the ratio of characters used and the total character limit.

_footer: - Supporting text - Character counter_
_altText: A side by side view of a text field with supporting text aligned with the trailing side, and a character counter aligned with the trailing side._

### Error text

For text fields that validate their content such as passwords, replace supporting text with error text. Swapping supporting text with error text prevents new lines of text from bumping content and changing the layout.

- If only one error is possible, error text should describe how to avoid the error
- If multiple errors are possible, error text should describe how to avoid the most likely error

_footer: Swap supporting text with error text_
_altText: Mobile UI of a sign up form indicating a invalid entry, and a hint on how to resolve as supporting text below the container._

_footer: Don't add error text in addition to supporting text, as their appearance will shift content_
_altText: Mobile UI of a sign up form with an invalid text field entry. The regular supporting text remains above the error message._

_footer: Long errors can wrap to multiple lines if there isn't enough space to clearly describe the error. In this case, ensure padding between text fields is sufficient to prevent multi-lined errors from bumping layout content._
_altText: Mobile UI of a sign up form with an invalid text field entry. The error message wraps to 2 lines._

### Error icon

It’s strongly recommended to show an error icon when the text field is in the error state. 

This highlights the error for people with visual impairments, and provides an additional sensory indicator.

_footer: The error icon is an important second visual indicator that a text field has an error_
_altText: 2 text fields with error messages. The active text field has a thicker border. Both text fields have a trailing error icon._

### Icons & images

Icons in text fields are optional. Text field icons can: 

- Describe valid input methods such as a microphone icon
- Provide affordances to access additional functionality such as clearing the content of a field
- Express an error

Leading and trailing icons change their position based on LTR or RTL contexts.

Images that are 24dp in height can be placed inside of text fields. This image height allows for optimal top and bottom padding within the field and is consistent with icon size recommendations.

- **Icon signifier**Icon signifiers can describe the type of input a text field requires, and be touch targets for nested components. For example, a calendar icon may be tapped to reveal a date picker.
- **Valid or error icon**Iconography can indicate both valid and invalid inputs, making error states clear for colorblind users.
- **Clear icon**Clear icons let a person clear an entire input field. They appear only when input text is present.
- **Voice input icon**A microphone icon signifies that people can input characters using voice.
- **Dropdown icon**A dropdown arrow indicates that a text field has a nested selection component.
- **Image**An image can help contextualize the required input text such as a credit card number.

_footer: - Icon signifier - Valid or error icon - Clear icon - Voice input icon - Dropdown icon - Image_
_altText: Side by side view of text fields with different icons and images as trailing elements within the container._

### Read-only fields

Read-only text fields display pre-filled text that people cannot edit. 

A read-only text field is styled the same as a regular text field and is clearly labeled as read-only.

_footer: A filled read-only text field_
_altText: Read only filled text field._

_footer: An outlined read-only text field_
_altText: Read only outlined text field._

## Adaptive design

As layouts adapt to larger screens and different breakpoints, apply flexible container dimensions to text fields. Set minimum and maximum values for margins, padding, and container dimensions as layouts scale so that typography adjusts for better reading experiences.

_footer: For compact breakpoints, text fields can span the full width of the display. For medium and expanded breakpoints, text fields should be bound by flexible margins or other containers._
_altText: UI for creating a new album in a side by side view on mobile and tablet._

As text fields expand in fluid layouts, avoid maintaining fixed margins and typography properties. This can lead to extra long text fields. 

For example, text fields should not span the full width of a large screen.

_footer: Don’t use fixed text field margins on large devices. Text fields shouldn’t span the full width of a large screen._
_altText: Tablet UI with text fields spanning the complete width of the screen._

### Density

Dense text fields enable people to scan and take action on large amounts of information.

_footer: A form with dense text fields_
_altText: Tablet UI with desne text field as part of event creation form._

#### **Avoid applying density by default**

Don't apply density to text fields by default. This lowers their targets below the recommended 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure this density setting can be easily reverted when it's active, keep all the targets to change it at a minimum of 48x48 CSS pixels each.

<!-- section: Accessibility -->

## Use cases

User should be able to:

- Navigate to and activate a text field with assistive technology
- Input information into the text field
- Receive and understand supporting text and error messages
- Navigate to and select interactive icons

## Interaction & style

The containers for both filled and outlined text fields provide the same functionality. Changes to color and thickness of stroke help provide clear visual cues for interaction.

_footer: Filled text fields_
_altText: Filled text field in enabled (empty) state and in focused (populated state) have visual cues to identify their state._

_footer: Outlined text fields_
_altText: Outlined text field in enabled (empty) state and in focused (populated state) have visual cues to identify their state._

Containers improve the discoverability of text fields by creating contrast between the text field and surrounding content. 

In some contexts, outlined text fields can improve the perception of the fields with a 3:1 or greater contrast ratio between the container outline and the background.

_footer: Make sure the container outline has a minimum contrast of 3:1 to the background_
_altText: An outlined text field with label text that passes the minimum contrast of 3:1._

_footer: Don't choose colors that won't pass Material's minimum contrast of 3:1_
_altText: An outlined text field with label text fails the minimum 3:1 contrast._

## Keyboard navigation

Keys | Actions |
Tab | Focus lands on (non-disabled) text field |

## Labeling elements

If the UI text is correctly linked, assistive tech (such as a screenreader) will read the UI text followed by the component’s role.

The accessibility label for a text field is the same as the text field label.

_footer: A text field’s label should include its UI text_
_altText: The text field  and accessibility label both read “Email.” The role is “textbox.”_

For text fields with interactive trailing icons, the accessibility label clarifies its function.

For example, when a password is hidden, the label for the view icon is "Show password," and when the password is visible, the label is "Hide password."

When an icon has no actionable role, like an error icon, the label is "Error."

_footer: When a trailing icon in the field acts as a button, the label should clarify function, while the role explains the component type_
_altText: The trailing icon’s accessibility label “Show Password.” The role is “Button.”_

The prefix and suffix of a text field provides symbols and abbreviations to help users enter the correct values. 
 
The accessibility label for prefix and suffix needs to have a unique id attribute, for example, the currency name for a currency symbol prefix.

_footer: A form containing fields with both a prefix for currency, and a suffix for email address_
_altText: Text field accessibility labels “UI text” are “Euro” for a currency prefix and “At gmail dot com” for the email address suffix._

When there is an error, "alert" is applied to the role and the error message to the text label.

If a text field displays both supporting text and error text, the label should include the supporting text first, followed by the error text.

_footer: Text field error messages should be given an “alert” role in accessibility labels_
_altText: The text field accessibility labels is: UI text “Not a valid ZIP code.” The role is “Alert.”_

The accessibility label for the character counter clarifies the number of characters that can be entered into the text field.

_footer: The remaining character counter should be called “character count” within the label_
_altText: A character counter's accessibility label  reads: UI text (“Character count, 5/20”)_

The text displayed in the supporting text is also used for its accessibility label.

_footer: Text field supporting text should have its own accessibility label_
_altText: The accessibility label uses the supporting text. It reads: UI text (“Please use the company email address”). Role [No role]._

If a text field requires input, indicate so with an asterisk at the end of the text field label. The accessibility label must include the asterisk.

_footer: A required text field’s accessibility label should include any supporting text_
_altText: Accessibility label reads: UI text (“Username*”).  The role is “Textbox.”_

---

<!-- Source: m3.material.io · components_checkbox · updated 2026-08-12T09:53:04.800Z · CC-BY 4.0 (Google) -->

## Checkbox



<!-- section: Overview -->

- Use checkboxes (instead of switches or radio buttons) if multiple options can be selected from a list
- Label should be scannable
- Selected items are more prominent than unselected items

_footer: Unselected, selected (hover), and indeterminate checkboxes_
_altText: 3 checkboxes in a diagram demonstrating all three states._

## Availability & resources

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color

-
States: New indeterminate states as well as error states for unselected, selected, and indeterminate

_footer: M2_
_altText: Color mapping of a checkbox in M2._

_footer: M3_
_altText: Color mapping of a checkbox in M3 with new color._

<!-- section: Specs -->

## Tokens & specs

Browse the component elements, attributes, tokens, and their values.

## Checkbox

_footer: - Container - Icon_
_altText: Diagram of checkbox indicating the 2 parts of its anatomy._

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: - Checkbox - State-layer - Icon_
_altText: Checkbox color roles in light and dark themes._

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

_footer: The text color remains the same regardless if the checkbox is selected or not_
_altText: Checkboxes with text labels. The text color is the same for checked and unchecked checkboxes._

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Side by side view of states in light and dark themes._

## Measurements

_altText: Diagram of a selected checkbox with a container width and height of 18dp and a state-layer width and height of 40dp._

Attribute | Value |

Container size
 |
18dp
 |

Container corner shape
 |
2dp
 |

Icon size
 |
18dp
 |

Icon alignment
 |
Center-aligned
 |

Target size
 |
48dp
 |
State-layer size | 40dp |

<!-- section: Guidelines -->

_footer: Checkboxes in a list of items_
_altText: A list of burger additions represented with checkboxes._

## Usage

Use checkboxes to: 

- Select one or more options from a list
- Present a list containing sub-selections
- Turn an item on or off in a desktop environment
- Visually group similar options together

_footer: Checkboxes select multiple, related options_
_altText: List of 80's songs indicating choice through checkbox selection._

Checkboxes should be used instead of switches if multiple, related options can be selected from a list. Checkboxes visually group similar items effectively and take up less space than switches.

_footer: Checkboxes let users select one or more options from a list. A parent checkbox allows for easy selection or deselection of all items._
_altText: List indicating choice with checkbox selection._

_footer: If a list consists of multiple options, don't use switches. Instead, use checkboxes. Checkboxes imply the items are related, and take up less visual space._
_altText: A list with multiple switches selected._

### Alternate selection controls

Checkboxes, radio buttons, and switches are the three main  selection controls. They all help people make choices, like selecting options or switching settings on or off.

-
Use checkboxes to select multiple related options in a list.

-
Use radio buttons to select a single option in a list.

-
Use switches to select standalone or more verbose options in a list, like settings.

_footer: Radio buttons_
_altText: Diagram of 2 radio buttons, one selected and one unselected._

_footer: Switches_
_altText: Diagram of 2 switches, one selected and one unselected._

## Anatomy

_footer: 1. Container  2. Icon_
_altText: Diagram of checkbox indicating the 2 parts of its anatomy._

## Responsive layout

In expanded breakpoints, placing checkboxes within a contained region such as a side sheet can help group related controls and available actions.

_footer: A side sheet can group related controls on larger screens_
_altText: Desktop screen showing music albums and a side sheet containing checkboxes for filtering music genres._

## Behavior

Multiple checkboxes in a list can be selected.

_footer: Selecting multiple items in a list using checkboxes_
_altText: Using checkboxes to select a list of extra ingredients, like pickles and tomatoes, to add to a meal._

Checkboxes can have a parent-child relationship with other checkboxes.

- When the parent checkbox is checked, all child checkboxes are checked
- If a parent checkbox is unchecked, all child checkboxes are unchecked
- If some, but not all, child checkboxes are checked, the parent checkbox becomes an indeterminate checkbox. Checking an indeterminate checkbox checks all child items.

_footer: Use a parent checkbox to make it more efficient to select many items_
_altText: Checking parent checkbox also checks child items. Unchecking one child item makes parent indeterminate._

When selected, a checkbox clearly and instantly communicates its selected state.

If used to turn something on or off, the action should be immediately executed.

_footer: Turning an item on or off using a checkbox_
_altText: Selecting a checkbox for turning on dark mode immediately changes the phone theme._

<!-- section: Accessibility -->

## Use cases

People should be able to use assistive technology to:

-
Navigate to a checkbox   

-
Toggle the checkbox on and off

-
Get appropriate feedback based on input type documented under [Interaction & style](/m3/pages/checkbox/accessibility#6a2f55e5-2fa0-4204-b6d1-62362dda89c7)

## Interaction & style

Users should be able to select either the text label or the checkbox to select an option.

_footer: A checkbox selected via the text label_
_altText: In a list, checkboxes for 2 items are selected via their text labels._

The parent checkbox has three states: selected, unselected, and indeterminate. 

Checkboxes can be selected or unselected regardless of the state of the other checkboxes in a group. 

If some, but not all, child checkboxes are checked, the parent checkbox becomes indeterminate. Selecting an indeterminate parent checkbox will check all of its child checkboxes.

_footer: An indeterminate selection indicating that at least one checkbox is selected within a group_
_altText: In a list, a child checkbox for 1 item is selected and the parent checkbox is in indeterminate state._

## Avoid applying density by default

Don't apply density to checkboxes by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

## Keyboard navigation

Keys | Actions |
**Tab** | Moves focus to enabled chip or chip group |
**Space** or **Enter** | Activates, selects, or deselects the focused chip |
**Backspace** or **Delete** | Removes currently focused input chip |
**Arrows** | Moves focus between chips |

## Labeling elements

If the UI text is correctly linked to the checkbox, assistive tech (such as a screen reader) will read the UI text followed by the component’s role.

The accessibility label for an individual checkbox is typically the same as its adjacent text label.

_footer: The accessibility label clearly states the text label of the checkbox_
_altText: Accessibility labels of a checkbox._

---

<!-- Source: m3.material.io · components_radio-button · updated 2026-07-17T07:17:47.331Z · CC-BY 4.0 (Google) -->

## Radio button



<!-- section: Overview -->

- Use radio buttons (not switches) when only one item can be selected from a list
- Label should be scannable
- Selected items are more prominent than unselected items

_footer: Radio buttons can be selected_
_altText: 1 radio button is selected from a list of 4 radio buttons of different ringtones._

## Resources & availability

## What’s new

- Color: New color mappings and compatibility with dynamic color

_footer: Radio buttons feature new color mappings_
_altText: App screen with 1 active button selected from list of 3 buttons._

<!-- section: Specs -->

_footer: - Radio button icon_
_altText: Diagram of enabled radio button._

## Tokens & specs

[Learn more about design tokens](/m3/pages/design-tokens/overview)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Radio button color roles used for light and dark themes:  - Primary - On surface variant_
_altText: Diagram of selected and unselected radio button colors._

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

_footer: The text color remains the same regardless if the button is selected or not_
_altText: Radio buttons with labels. The labels are the same color for both selected and unselected radio buttons._

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: - Enabled - Hover - Focus - Pressed - Disabled_
_altText: Diagram of radio button states including enabled, hover, focus, pressed, and disabled._

[State specs are in the token module above](/m3/pages/radio-button/specs#3eef19a6-cdcb-4ecf-b1af-2b8095d485ac)

## Measurements

_footer: Radio button size measurements_
_altText: Diagram of radio button layout values._

Attribute
 | Value
 |
Icon size
 | 20dp |
State layer size
 | 40dp |
Target size
 | 48dp |

<!-- section: Guidelines -->

_footer: Radio buttons_
_altText: 1 radio button is selected from a list of 4 radio buttons of different ringtones._

## Usage

Radio buttons are the recommended way to allow users to make a single selection from a list of options. 

Only one radio button can be selected at a time.

_footer: Radio buttons should always be accompanied by clear inline labels_
_altText: 1 of 3 languages is chosen using radio buttons. Selecting a language deselects the previous 1._

Use radio buttons to:

- Select a single option from a set
- Expose all available options

_footer: Radio buttons are single-select, unlike checkboxes which are multi-select_
_altText: 2 radio buttons are used for allowing or turning off notifications. 2 checkboxes are used for microphone and location access._

_footer: Use radio buttons when only one option can be selected from a list_
_altText: Filter page with 4 sort by options as radio buttons. Relevance is selected._

_footer: Use checkboxes when multiple options can be selected from a list_
_altText: Meal options page with the Additions item selected, along with 4 nested checkboxes for selecting various toppings. All checkboxes are selected._

Avoid nesting radio buttons or using radio buttons to select multiple options.

_footer: Don’t nest radio buttons_
_altText: Selected radio button with 2 nested radio buttons._

_footer: Don’t allow radio buttons to select multiple options_
_altText: 2 radio buttons selected at once from a list of 3 buttons._

### Alternate selection controls

Radio buttons are one of several selection controls, which allow people to make choices such as selecting options or switching settings on or off.

Switches and checkboxes are alternative selection controls that can be used to change settings or preferences.

_footer: Switches_
_altText: A selected and unselected switch._

_footer: Checkboxes_
_altText: An unselected and selected checkbox._

Use radio buttons when there are five or fewer options.

Consider using a drop-down menu instead of radio buttons when it’s important to save space on a screen. However, drop-down menus require additional steps for a person, both in the number of clicks and cognitive effort.

_footer: Use radio buttons when there are five or fewer options_
_altText: A filter UI with 1 radio button selected from a list of 3 buttons._

_footer: Consider using a drop-down menu instead of radio buttons when space is constrained_
_altText: A dropdown menu with a list of 4 options._

## Anatomy

_footer: - Selected icon - Adjacent label text - Unselected icon_
_altText: 3 elements of a radio button._

### Adjacent label text

Always pair radio buttons with an adjacent label describing what the radio button selects.

Because only one radio button can be selected at a time, each choice must have its own label.

_footer: Radio button always need label text_
_altText: Checkout page with 2 radio buttons for home and office addresses. The labels are "Home" and "Office."_

## Placement

Radio buttons are often arranged in stacked layouts.

_altText: Settings page with 3 stacked radio buttons for selecting a language._

Radio buttons should be vertically listed and have one option always selected.

_footer: Radio buttons should always have one option pre-selected_
_altText: 3 radio buttons with 1 option selected._

_footer: Avoid using horizontal radio button lists_
_altText: 2 radio buttons side by side with 1 option selected._

## Behavior

A radio button is successfully selected when a person clicks or taps either the radio button icon or the label.

_footer: Radio buttons should take effect immediately, unless they're in a dialog or page that needs to be saved_
_altText: Selecting the radio button for dark theme instantly changes the screen to dark theme._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

-
Navigate to a radio button

-
Select a radio button

-
Get appropriate feedback based on input type

## Interaction & style

A radio button can be either selected or unselected. Selecting one radio button deselects any others. A radio group can start with one radio button selected, or none selected.

Once a radio button is selected, the group can’t be deselected. To let people opt out of their selection, either provide a **Not applicable** or **No option** radio button, or provide a separate way to deselect all radio buttons, like **Clear selection**.

People should be able to select either the text label or the radio button to select an option.

_footer: Only one radio button is selected at a time_
_altText: Selecting between radio buttons for a home and office address._

### Avoid applying density by default

Don't apply density to radio buttons by default. This lowers their targets below Material's recommendation of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure this density setting can be easily reverted when it's active, keep all targets to change it at a minimum of 48x48 CSS pixels each.

## Initial focus

When outside the radio group, **Tab** moves focus directly to the selected radio button, or the first one if none are selected. 

**Shift+Tab** instead focuses on the last radio if none are selected. 

Use the **arrows** to navigate between options.

_footer: Tab brings the focus to the initially selected item or the initial radio option_
_altText: The Tab key focuses on the first of 2 stacked radio buttons._

_footer: Arrows move to next element in a list_
_altText: The up and down arrow keys move through a list of stacked radio buttons._

## Keyboard navigation

Keys | Actions |
**Tab** | Moves focus into the group to the selected radio button, or the first if none are selected |
**Shift** + **Tab** | Moves focus into the group to the selected radio button, or the last if none are selected |
**Arrows** | Moves focus and selects the previous or next radio button. Wraps focus and selection between the first and last radio buttons. |
**Space** | Selects a focused radio button. If already selected, does nothing. |

## Labeling elements

If the UI text is correctly linked to the radio button, assistive tech such as a screenreader will read the UI text, followed by the component’s role.

The accessibility label for a group of radio buttons is typically the same as its title. The role is **Radio group**.

_footer: Label the radio group based on the category title_
_altText: Accessibility tags for a radio button group._

The accessibility label for an individual radio button is typically the same as its adjacent text label.

_footer: Label the radio button based on its label text_
_altText: Accessibility tags for a radio button._

---

<!-- Source: m3.material.io · components_switch · updated 2026-07-17T07:03:01.922Z · CC-BY 4.0 (Google) -->

## Switch



<!-- section: Overview -->

-
Use switches (not radio buttons) if the items in a list can be independently controlled

-
Switches are the best way to let people adjust settings

-
Make sure the switch’s selection (on or off) is visible at a glance

_footer: Switches can be toggled on and off_
_altText: A switch in two states, off and on._

## Availability & resources

## Differences from M2

-
Accessibility: Visual presentation is more accessible

-
Color: New color mappings meet Material's non-text-contrast requirements in addition to compatibility with dynamic color

-
Icons: Ability to have an optional icon within the switch handle

-
Layout: Track is taller and wider

_footer: M2: Switches have a circular handle that extends beyond the edge of the track_
_altText: M2 switches in off and on states._

_footer: M3: Switches have a taller and wider track, new color mappings, and the ability to show an icon in the handle_
_altText: M3 switch shown toggled off and toggled on. When switched on, it has a checkmark icon._

<!-- section: Specs -->

_footer: - Track - Handle (formerly "thumb") - Icon_
_altText: 3 elements of a switch._

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Switch color roles used for light and dark themes:  - Surface container highest - Outline - Outline - Primary - On primary - On primary container_
_altText: 6 color roles of a switch in light and dark themes._

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

_footer: The text label uses **on surface**. Supporting text may use **on surface variant**._
_altText: The large body text adjacent to switches uses "on surface" color and the body text uses "on surface variant."_

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states)

_footer: - Enabled   - Hovered   - Focused   - Pressed   - Disabled_
_altText: 5 states of a switch shown in light and dark themes._

[State specs are in the token module above](/m3/pages/switch/specs#3708644e-b4d7-4237-bb0a-7afeeae4a9b0)

## Measurements

_footer: Switches without icons_
_altText: Measurements of switches without icons._

_footer: Pressed switches without icons_
_altText: Measurements of pressed switches without icons._

_footer: Switches with icons_
_altText: Measurements of switches with icons._

_footer: Pressed switches with icons_
_altText: Measurements of pressed switches with icons._

Element
 |
Attribute
 |
Value
 |

Track
 |
Height
 |
32dp
 |

Width
 |
52dp
 |

Outline width
 |
2dp
 |

Shape
 |
[md.sys.shape.corner.full](/m3/pages/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e)
 |

Handle
 |
Height (unselected)
 |
16dp
 |

Height - with icon
 |
24dp
 |

Height (selected)
 |
24dp
 |

Height (pressed)
 |
28dp
 |

Width (unselected)
 |
16dp
 |

Width - with icon
 |
24dp
 |

Width (selected)
 |
24dp
 |

Width (pressed)
 |
28dp
 |

Shape
 |
[md.sys.shape.corner.full](/m3/pages/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e)
 |

State layer
 |
Size
 |
40dp
 |

Shape
 |
[md.sys.shape.corner.full](/m3/pages/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e)
 |

Target
 |
Size
 |
48dp
 |

Icon
 |
Size (selected)
 |
16dp
 |

Icon
 |
Size (unselected)
 |
16dp
 |

## Configurations

- Without icons
- Icon on selected switch
- Icon on selected and unselected switch

_altText: 3 example switches with and without icons in on and off states._

<!-- section: Guidelines -->

_footer: Switches change settings and other options immediately_
_altText: A switch in 2 states, off and on._

## Usage

Switches are best used to adjust settings and other standalone options. 

They make a binary selection:

-
On and off

-
True and false

The effects of a switch should start immediately, without needing to save.

_footer: Use a switch to turn an option on and off_
_altText: Toggling a switch turns on dark mode in Settings on a mobile device._

Use switches to:

- Toggle a single item on or off
- Immediately activate or deactivate something

_footer: Switches are commonly used on mobile to turn settings on or off_
_altText: Switch used in notification settings to turn on and off the "play over notifications" function._

Switches control binary options, not opposing ones. A binary option represents a single selection that's either on or off.

Opposing options are when only one option in a set can be selected at a time, like a list or map view. Use a connected button group instead.

_footer: Use a connected button group to choose between opposing options_
_altText: A connected button group with options of List View and Map View._

_footer: Avoid using switches to toggle between opposing options_
_altText: A switch with non-binary options of List View and Map View._

### Alternate selection controls

Checkboxes, radio buttons, and switches are the three main kinds of selection controls. They help people make choices, like selecting options or turning settings on and off.

Use checkboxes to select multiple related options in a list.

Use radio buttons to select a single option in a list.

Use switches to select standalone or more verbose options in a list, like settings.

_footer: Checkboxes_
_altText: 2 checkboxes, 1 unchecked and 1 checked._

_footer: Radio buttons_
_altText: 2 radio buttons, 1 in an enabled state, 1 in a disabled state._

_footer: Use checkboxes (not switches) to let people select one or more options from a list_
_altText: Mobile screen with checkboxes to select list items and call to action button to update the list._

_footer: A switch can't replace a button. People expect a call to action to be a button, not a switch._
_altText: Mobile screen with checkboxes to select list items and call to action switch to update the list._

_footer: Use radio buttons (not switches) when only one item can be selected from a list_
_altText: Radio buttons used to select a language for a mobile app._

_footer: Avoid using a switch to select multiple options that require people to save. Switches should be immediate. Use checkboxes instead._
_altText: Mobile screen with switches to select list items and call to action button to update the list._

## Anatomy

_footer: - Track - Handle - Icon (optional)_
_altText: 3 elements of a switch._

### Icon (optional)

The switch handle can contain an optional icon.

_footer: The icon within the handle should always communicate the switch's selection_
_altText: A checkmark appears on the filled circle of a handle when the switch is toggled on._

Icons can be used to visually emphasize the switch’s selection. The icon’s meaning should be clear and unambiguous to help the people understand whether switch is on or off.

_footer: Use icons that clearly communicate whether the switch is on or off, such as an X and a checkmark_
_altText: 2 switches, the unselected state icon is an X, and the selected state is a checkmark._

_footer: Avoid using more ambiguous or non-binary icons, such as a moon or edit icon_
_altText: A switch’s unselected handle icon is a moon and the selected state icon is a pencil._

### Label text

Switches should always be paired with an inline label describing what the switch controls when selected.

_footer: Keep labels short and direct. A label should describe what the control does when the switch is on._
_altText: Switch label text: 1. Permission manager, App has access to your data. 2. Camera access, app has access to your camera. 3. Show password._

_footer: Don't add label text into the switch; the font size would be too small to be accessible. Use an appropriate icon instead._
_altText: On a mobile screen’s privacy settings, 2 switches have “On” label text and checkmark icons. The last switch has “Off” label text and no icon._

## Placement

Switches are often arranged in stacked layouts.

_footer: Settings screens are common places to use switches_
_altText: Screen showing labels and stacked switches in varying on/off modes._

## Behavior

A switch is successfully toggled when the handle slides to the other side of the track after an interaction.

_footer: When selected, the switch handle slides to the opposite end of the track_
_altText: A switch is toggled to turn on airplane mode and Wi-Fi switch automatically turns off._

When a person toggles a switch, its handle size changes and the corresponding action takes effect immediately.

_footer: The **on** state of the switch is indicated by a larger handle size_
_altText: When selected the switch’s handle gets larger and a checkmark appears on the filled circle._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

-
Navigate to a switch with a keyboard or switch input

-
Toggle the switch on and off

-
Get appropriate feedback based on input type documented under [Interaction & style](/m3/pages/switch/accessibility#c0e9fae1-48df-428b-b028-4f7be071ada3)

## Interaction & style

The switch handle increases in size to indicate interactivity for both touch and cursor control interactions.

**Touch**
When tapped or dragged, the handle size grows, providing interaction feedback.

**Cursor**
When hovered (in both on and off states), the hover area grows, providing a visual cue that the handle is interactive. When clicked, the handle size grows.

_footer: Touch: Tap, Drag_
_altText: The switch handle increases in size when tapped and dragged._

_footer: Cursor: Hover, Click_
_altText: The cursor changes from an arrow to a hand pointer when hovering over and clicking the switch._

### Avoid applying density by default

Don't apply density to switches by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can easily be reverted when it's active, keep all targets to change it at a minimum 48x48 CSS pixels each.

## Initial focus

Initial focus lands directly on the switch’s handle, since it’s the primary interactive element of the component.

_footer: Focus lands on the switch handle_
_altText: The focus is on the switch handle, which is toggled on._

_footer: The switch is toggled using **Space** or **Enter**_
_altText: Space or Enter is used to toggle the switch off._

## Keyboard navigation

Keys | Actions |
**Tab** | Focus lands on the switch handle |
**Space**or**Enter** | Toggles the handle on and off |

## Labeling elements

The accessibility label for a switch uses the adjacent label text if implemented correctly. 

Assistive tech such as a screen reader will read the UI text followed by the component’s role.

_footer: A switch’s accessibility label can incorporate its adjacent UI text_
_altText: “Dark theme” is the switch’s adjacent label text and the accessibility label._

When the visible UI text is ambiguous, accessibility labels need to be more descriptive. For example, a switch visibly labelled **Photo album** would benefit from additional information to clarify the switch’s function.

Consider making the adjacent label text more descriptive when possible. This reduces the need for different accessibility text.

_footer: While the visible label text reads **Photo album**, the accessibility label for this switch clarifies its function: **Photo album access**_
_altText: The accessibility label for the switch is “Photo album access” though the label text is “photo album.”_

---

<!-- Source: m3.material.io · components_sliders · updated 2026-07-17T07:13:18.037Z · CC-BY 4.0 (Google) -->

## Sliders



<!-- section: Overview -->

-
Three variants: Standard, centered, range

-
Has five sizes, vertical and horizontal orientation, and an optional inset icon

-
Sliders should present the full range of available values

-
The slider value should take effect immediately

_footer: Sliders change values along a range_
_altText: A vertical slider changes the brightness of bedroom lights._

## Availability & resources

## M3 Expressive update

**May 2025**

The slider includes expressive configurations for orientation, shape sizes, and an inset icon. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Updated on Android Views (MDC-Android) and Jetpack Compose.

Variants and naming: 

-
Changed **continuous** slider to **standard** slider

-
The **discrete** slider is now the **stops** configuration

New configurations: 

-
Orientation: Horizontal, vertical

-
Optional inset icon (standard slider only)

-
Sizes: XS (existing default), S, M, L, XL

_footer: - Standard slider - Centered slider - Range slider_
_altText: 3 M3 Expressive sliders._

## Previous updates

### Visual refresh to improve non-text contrast

**Dec 2023:** Updated on Android Views (MDC-Android) and Jetpack Compose.

-
**Configuration:** Added centered configuration and range selection

-
**Shape:**New shape for slider tracks and handles. Slider elements change shape when selected.

-
**Motion:** Slider handle adjusts width upon selection. Slider tracks adjust in shape when sliding to the edge.

-
**Color:**Refreshed color mappings

_footer: M3 visual refresh: Sliders have a stop indicator, larger label text, and a vertical handle that narrows when pressed. Centered sliders start from the middle instead of the leading edge._
_altText: M3 visually-refreshed slider._

## Differences from M2

- **Color**: New color mappings and compatibility with dynamic color

_footer: M2: Sliders have a circular handle and a small label when pressed_
_altText: M2 slider._

_footer: M3: Sliders have new color mappings and support dynamic color_
_altText: Original M3 slider._

<!-- section: Specs -->

## Variants

_footer: - Standard  - Centered  - Range_
_altText: 3 variants of sliders._

Variant
 |
M3
 |
M3 Expressive
 |

Standard
 |
Available as “continuous” slider
 |
Available
 |

Centered
 |
Available (web only)
 |
Available
 |

Range
 |
Available
 |
Available
 |

Discrete
 |
Available
 |
Available as “stops” configuration
 |

## Configurations

_footer: - Orientation: Horizontal, vertical - Size: XS, S, M, L, XL_
_altText: Orientation and size configurations of sliders._

_footer: - Inset icon - Stops - Value indicator_
_altText: Optional anatomy configurations of sliders._

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Inset icon
 |
No (default)
 |
Available
 |
Available
 |

Yes
 |
--
 |
Available
 |

Orientation
 |
Horizontal (default)
 |
Available
 |
Available
 |

Vertical
 |
--
 |
Available
 |

Size
 |
XS (default)
 |
Available
 |
Available
 |

S, M, L, XL
 |
--
 |
Available on Android Views (MDC-Android).
Available as tokens on other platforms.*

 |

Stop indicators
 |
No (default), Yes
 |
Available as “discrete” slider
 |
Available
 |

Value Indicator
 |
No (default), Yes
 |
Available
 |
Available
 |

*Configurations only available using tokens don’t have implemented presets in code. To change the size, swap the default size tokens md.comp.slider.**xsmall**.[...] with those of the desired size.

## Tokens & specs

Slider tokens are organized into a common token set, and token sets for each size. Switch token sets from the table’s menu. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Anatomy

_footer: - Value indicator (optional) - Stop indicators (optional) - Active track - Handle - Inactive track - Inset icon (optional)_
_altText: 6 elements of a slider._

## Color

_footer: Slider color roles used for light and dark schemes:  - Inverse surface - Inverse on surface - Primary - On primary - Primary - Secondary container - On secondary container - On secondary container - On primary_
_altText: 9 color roles of a slider._

## States

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: 5 states of sliders in light and dark schemes._

## Measurements

_footer: Padding and size measurements for common sliders_
_altText: Common slider padding and size measurements._

_footer: Padding and size measurements for XS, S, M, L, and XL sliders_
_altText: Slider padding and size measurements at each size configuration, XS to XL._

Attribute | XS | S | M
 | L | XL |
Track height | 16dp | 24dp | 40dp | 56dp | 96dp |
Label container height
 | 44dp |
Label container width | 48dp |
Handle height
 | 44dp | 44dp | 52dp | 68dp | 108dp |
Handle width
 | 4dp |
Track shape | 8dp | 8dp | 12dp | 16dp | 28dp |
Inset icon size | -- | -- | 24dp | 24dp | 32dp |

<!-- section: Guidelines -->

_footer: Sliders can adjust values in real time, such as image attributes_
_altText: Photo editor with sliders labeled pop, sharpen, and denoise being adjusted._

## Usage

Sliders are used to select values along a track. They’re ideal for adjusting settings such as volume and brightness, or changing the intensity of image filters.

Sliders can use icons or labels to represent a numeric or relative scale.

_footer: Use sliders to pick a value from a range, like volume loudness_
_altText: Sound settings screen with continuous sliders labeled call volume and alarm volume._

Changes made with sliders must take effect immediately, so people can understand the effects of their selection as they're moving the slider.

_footer: Selection changes are immediate_
_altText: The brightness slider changes the screen’s brightness in real time._

There are three different variants of sliders: **standard**, **centered**, and **range:**

Standard sliders select one value from a range of values. Use this when the slider should start from zero or the beginning of a sequence.

_footer: Horizontal standard slider_
_altText: Horizontal standard slider with an end stop indicator._

_footer: Vertical standard slider_
_altText: Vertical standard slider  with an end stop indicator._

Centered sliders select a value from a positive and negative value range. Use this when zero, or the default value, is in the middle of the range.

_footer: Horizontal centered slider_
_altText: Horizontal centered slider with a negative value and visible stop indicators at each end._

_footer: Vertical centered slider_
_altText: Vertical centered slider with a negative value and visible stop indicators at each end._

Range sliders select two values on one slider to create a range. Use this when defining a minimum and maximum value.

Avoid using range sliders vertically, as this can add too much cognitive load. People are used to most sliders being horizontal.

_footer: Horizontal range slider_
_altText: Horizontal range selection slider with 2 values selected, and a stop indicator at each end._

_footer: Because of the additional cognitive load of a range slider, avoid using it in vertical orientation._
_altText: Vertical range slider with 2 values selected, and a stop indicator at each end._

## Anatomy

_footer: - Value indicator (optional) - Stop indicators (optional) - Active track - Handle - Inactive track - Inset icon (optional)_
_altText: 6 elements of a slider._

### Track

The track shows the full range of values that can be selected on the slider. It has two sections: active and inactive.

- The **active**section of the track is from the minimum value to the handle. For range sliders, the active track is between the two handles.
- The **inactive** section of the track is from the handle to the maximum value, or outside the two handles of a range slider.

For left-to-right (LTR) languages, the values increase from left to right. For right-to-left (RTL) languages, this is reversed.

_footer: The track on a slider shows the available range_
_altText: Sliders for font size and display size with stop indicators along the track._

### Handle

The handle can be moved along the track to choose a value.

When sliders have two handles, the handles choose the minimum and maximum values in a range.

The handle changes shape to indicate when it’s pressed.

_footer: A handle changes shape when it's being pressed or dragged_
_altText: The handle is a vertical line on the current value of the slider. It shrinks in width when selected._

_footer: Two handles are used for sliders with range selection_
_altText: 2 unselected handles on a slider with range selection._

## Configurations

### Value

The value displays the specific value that corresponds with the handle’s placement. 

A value appears when interacting with the corresponding handle. For range sliders, only one value should be shown at a time.

If the value is shown elsewhere, the indicator is not required.

_footer: A value can appear while the handle is being pressed or dragged_
_altText: A value of 50 is above a slider handle in the middle of the track._

_footer: For range sliders, the value only appears on one handle at a time_
_altText: A value of 75 is above the pressed range slider handle. The unselected slider doesn’t show the value._

Instead of showing the built-in value label, a separate text input field can be added outside of the slider. If this is added, the slider and value in this text field should automatically update to match each other.

Make sure people can tab to the text field directly after the slider.

_footer: Use **Tab** to navigate to values that are shown outside the slider, like a text input field_
_altText: Navigating to an adjacent text label, changing the value to 100 using arrow keys. The slider auto-updates based on input value._

### Stop indicators

Stop indicators show which predetermined values can be chosen on the slider. The slider handle snaps to the closest stop. 

Avoid having too many stop indicators on a slider, because it can become visually crowded and difficult to adjust the value.

All sliders have stops at the end of the inactive track to ensure at least a 3:1 contrast with the background. If the inactive track has this level of contrast already, the end stops can be removed.

_footer: Stop indicators show each available value on a slider_
_altText: Stop indicators are equally spaced out on a slider._

Icons or text can be added outside the slider to indicate the range of values and make the slider more accessible. This can be used instead of a stop indicator.

_footer: Plus and minus icons, or text, can be added to the left and right of the slider_
_altText: Plus and minus icons on each end of the slider._

### Orientation

Sliders can be oriented either horizontally or vertically, depending on what is best for your use case.

_footer: Standard slider in horizontal orientation_
_altText: Horizontal slider._

_footer: Standard slider in vertical orientation_
_altText: Vertical slider. Zero is at the bottom._

### Inset icon

Standard sliders that are M, L, or XL can include an icon within the track. This icon should illustrate what the slider controls. Avoid adding inset icons to XS or S sliders.

When there’s not enough space for the icon on the active track, like at a low value, the icon moves to the inactive track.

Consider swapping which icon is displayed at zero, like a volume icon becoming a mute icon.

_footer: Inset icons change placement based on the handle_
_altText: Inset icon on the active track when the handle is at 50%, and on the inactive track when the handle is at 0._

_footer: Don’t use an inset icon with sliders that have track thicknesses under 40dp_
_altText: An inset icon on an XS slider. The icon bounds are cut off by the slider container._

Don’t use inset icons on centered or range sliders. It makes it unclear where the start of the slider is.

_footer: Don’t use an inset icon on a centered slider_
_altText: Centered slider with an inset icon on one end, and a stop indicator on the other._

_footer: Don’t use an inset icon on a range slider_
_altText: Range slider with an inset icon on one end, and a stop indicator on the other._

### Size

Sliders come in different sizes: XS, S, M, L, and XL. Use larger sizes to increase the targets and provide a larger visual emphasis.

The active and inactive tracks should always be the same size.

_footer: - XS: 16dp - S: 24dp - M: 40dp - L: 56dp - XL: 96dp_
_altText: 5 sizes of sliders._

XL sliders should be reserved for hero moments, where the slider itself is the most important element on the page.

_footer: XL sliders should be the focus of the page_
_altText: An XL slider used to adjust living room temperature on mobile. No other controls are on screen._

## Behaviors

### Select & drag

Select a value by dragging the handle.

_footer: **Standard slider**: The handle drags smoothly_
_altText: Slider handle moves smoothly. The value increases and decreases by single digits._

_footer: **Slider with stop indicators:** The handle snaps to the closest stop indicator while dragged_
_altText: Slider handle snaps to the nearest multiple of 10 when moved._

### Select jump

Select a value by selecting part of the track.

_footer: Standard**slider**: The handle moves to the selected location_
_altText: Slider handle moves smoothly to selected value of the slider._

_footer: Slider with stop indicators: The handle moves to the closest stop indicator_
_altText: Slider handle moves smoothly to the closest stop indicator value._

### Select & arrow

Select a value using the keyboard.

**Tab:** Focus lands on handle 

**Arrows:**Selected value increases or decreases by one value or stop indicator

**Space & arrows:** Selected value increases or decreases by a larger interval or stop indicator

_footer: Standard**slider**: The handle moves one value_
_altText: Tab selects the slider, and arrow keys move the value by 1._

_footer: Slider with stop indicators: The handle moves to the next stop indicator_
_altText: Tab selects the slider, and arrow keys move the value by 10._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate to a slider
- Select a range by controlling a handle along a track
- Get appropriate feedback based on input type

## Interaction & style

The slider handle shrinks in width and the value appears to provide a visual cue to the user that the handle is being pressed.

**Touch**

When tapped or dragged, the handle width shrinks to provide interaction feedback, and the value appears.

**Cursor**

When hovered, the cursor changes. When clicked and dragged, the handle width shrinks, and the value appears.

_footer: The slider handle changes width during interaction_
_altText: Dragging a slider using a mouse cursor and by touch. Handle width shrinks when dragged._

### Focus and navigation

Initial focus lands directly on the handle, since it’s the primary interactive element of the slider.

The slider value can then be adjusted using the arrow keys or other keyboard navigation options.

_footer: Use arrow keys to change the slider value_
_altText: Using keyboard navigation on a slider. Tab to the handle, and use arrow keys to change the value._

## Color contrast

Use visual anchors so the end of the slider’s inactive track has at least 3:1 contrast with the background. The stop indicator makes the end easily visible on most backgrounds.

_footer: A stop indicator on the inactive track makes it easier to identify the end of the slider on a low-contrast background_
_altText: The inactive track has contrast below 3:1 with the background. The stop indicator is above 3:1. Slider is accessible._

Alternatively, icons or other elements that have a 3:1 contrast with the background can be used to indicate the ends of the slider’s inactive track.

_footer: Icons make it easier to identify the ends of the slider on a low-contrast background_
_altText: The inactive track has contrast ratio below 3:1 with the background. The icon is above 3:1. The slider is accessible._

## Keyboard navigation

Keys
 | Actions
 |
Tab
 | Moves focus to the slider handle |
Arrows
 | Increase and decrease the value by one value or one stop indicator |
Space & Arrows
 | Increase and decrease the value by one interval or one stop indicator |
Home or End
 | Set the slider to the first and last values on the slider |

## Labeling elements

The accessibility label for a slider is typically the same as the slider's adjacent text label. It should have the **slider** role.

_footer: A slider’s accessibility label should match the adjacent UI text_
_altText: Annotated aria tags of a slider._

If the UI text is correctly linked to the slider, assistive tech (such as a screenreader) will read the UI text followed by the component’s role.

_footer: Icon buttons placed outside the slider should have the button role_
_altText: Annotated aria tags of a slider with stepper icons._

---

<!-- Source: m3.material.io · components_chips · updated 2026-07-17T07:05:14.328Z · CC-BY 4.0 (Google) -->

## Chips



<!-- section: Overview -->

-
Use chips to show options for a specific context

-
Four variants: assist, filter, input, and suggestion

-
Chip elevation defaults to 0 but can be elevated if they need more visual separation

_footer: - Assist chip - Filter chip - Input chip - Suggestion chip_
_altText: 4 chip variants._

## Availability & resources

## Updates

**Aug 2024**

Updated stroke color from **outline** to **outline variant**.

_footer: The stroke color was softened to improve visual hierarchy between chips and buttons_
_altText: A chip with a clear outline is now a chip with a subtle outline._

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color

-
Shape: Rounded rectangle 

-
Variants: Action chips have been separated into assist chips and suggestion chips. Choice chips are now a subset of filter chips

_footer: M2: Variants of chips are input, choice, filter, and action chips_
_altText: M2 chip variants._

_footer: M3: Variants of chips updated to assist, filter, input, and suggestion chips_
_altText: M3 chip variants._

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and values.

## Assist chip

_footer: - Container - Label text - Leading icon_
_altText: Assist chip diagram numbering 3 elements._

### Assist chip color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Assist chip color roles used for light and dark themes:  - Surface container low (optional) - On surface - Outline - Primary_
_altText: Assist chip diagram numbering 4 color elements._

### Assist chip states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: Selected and unselected assist chip states:  - Enabled - Disabled - Hovered - Focused - Pressed - Dragged_
_altText: 36 assist chips illustrating combinations of styles, selection and non-selection, and 6 interaction states._

### Assist chip measurements

_footer: Assist chip padding and size measurements_
_altText: 3 assist chips with measurements shown for variants with and without a leading icon._

Attribute
 | Value
 |
Height
 | 32dp |
Shape
 | 8dp corner radius |
Icon size
 | 18dp |
Vertical label text alignment
 | Center-aligned |
Horizontal label text alignment
 | Start-aligned |
Left/right padding
 | 16dp |
Left/right padding with icon
 | 8dp |
Padding between elements
 | 8dp |

## Filter chip

_footer: - Container - Label text - Leading icon - Trailing icon_
_altText: Filter chip diagram numbering 4 elements._

### Filter chip color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Filter chip color roles used for light and dark themes:  - On surface variant  - On secondary container  - Secondary container  - Outline variant  - Surface container low (optional)_
_altText: Filter chip diagram numbering 4 color elements._

### Filter chip states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: Selected and unselected filter chip states:  - Enabled - Disabled - Hovered - Focused - Pressed - Dragged_
_altText: 24 filter chips showing combinations of elevated, non-elevated, selected, and non-selected styles, and 6 interaction states._

### Filter chip measurements

_footer: Filter chip padding and size measurements_
_altText: 3 filter chips with measurements shown for types with and without a leading icon and trailing icon._

Attribute
 | Value
 |
Container height
 | 32dp |
Container shape
 | 8dp corner radius |
Icon size
 | 18dp |
Vertical label text alignment
 | Center-aligned |
Horizontal label text alignment
 | Start-aligned |
Left/right padding
 | 16dp |
Left/right padding with icon
 | 8dp |
Padding between elements
 | 8dp |

## Input chip

_footer: - Container - Label text - Trailing icon - Leading icon_
_altText: Input chip diagram numbering 4 elements._

### Input chip color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Input chip color roles used for light and dark themes:  - On surface variant - Surface container low (optional) - On surface variant - On surface variant - Outline variant - Primary - Secondary container - On secondary container - On secondary container_
_altText: Input chip diagram numbering 5 color elements._

### Input chip states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: Selected and unselected input chip states:  - Enabled - Disabled - Hovered - Focused - Pressed - Dragged_
_altText: 33 input chips illustrating combinations of styles, selection and non-selection, and 6 interaction states._

### Input chip measurements

_footer: Input chip padding and size measurements_
_altText: 2 input chips with measurements: 1 with a trailing icon only; 1 with an avatar as a leading icon and a trailing icon._

Attribute
 | Value
 |
Container height
 | 32dp |
Container shape
 | 8dp corner radius |
Icon size
 | 18dp |
Avatar shape
 | 12dp corner radius |
Avatar size
 | 24dp |
Vertical label text alignment
 | Center-aligned |
Horizontal label text alignment
 | Start-aligned |
Left padding for avatar
 | 4dp |
Right padding for avatar
 | 8dp |
Left/right padding for icon
 | 8dp |
Padding between elements
 | 8dp |
Target size for close icon
 | Min 48dp |

## Suggestion chip

_footer: - Container - Label text_
_altText: Suggestion chip diagram numbering 2 elements._

### Suggestion chip color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Suggestion chip color roles used for light and dark themes:  - Outline - Surface container low (optional) - On surface variant_
_altText: Suggestion chip diagram numbering 3 color elements._

### Suggestion chip states

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](/m3/pages/interaction-states/overview)

_footer: Selected and unselected suggestion chip states:  - Enabled - Disabled - Hovered - Focused - Pressed - Dragged_
_altText: 24 suggestion chips illustrating combinations of styles across 6 interaction states._

### Suggestion chip measurements

_footer: Suggestion chip padding and size measurements_
_altText: 2 suggestion chips with measurements shown for variants with and without a leading icon._

Attribute
 | Value
 |
Container height
 | 32dp |
Container shape
 | 8dp corner radius |
Icon size
 | 18dp |
Vertical label text alignment
 | Center-aligned |
Horizontal label text alignment
 | Start-aligned |
Left/right padding without icon
 | 16dp |
Left/right padding with icon
 | 8dp |
Padding between elements
 | 8dp |

<!-- section: Guidelines -->

_footer: There are four variants of chips: Assist, filter, input, and suggestion_
_altText: 4 chip variants: Assist, filter, input, and suggestion._

## Usage

Chips help people enter information, make selections, filter content, or trigger actions. They're best used to help people accomplish their current task faster and easier.

_footer: Chips appear as a group of interactive elements_
_altText: 3 assist chips in restaurant review app._

### Chips aren’t buttons

Chips and buttons are similar. They both provide visual cues to prompt people to take actions and make selections. 

While buttons appear consistently and with familiar calls to action, chips are dynamic to the situation, and appear as a group of interactive elements.

Use chips to enhance a person's current journey and encourage action. Use buttons to progress them through the product and for significant actions.

_footer: Use chips to present contextual, supplemental options_
_altText: Chips used for “Reserve a table” and “Order delivery” in a restaurant app._

_footer: Avoid replacing major actions with chips. Actions that progress people to the next or previous step should always be displayed as buttons._
_altText: Chips used for Save and Cancel actions in a dialog._

Chips should dynamically offer various actions depending on the current task, whereas a button should be a persistent fixture of a layout. 

Chips represent forking paths for a current task, while buttons represent linear steps.

_footer: Use buttons for the final step in a task_
_altText: Button labeled “Save task” in a task management app._

_footer: Avoid using chips to finish or progress a task_
_altText: Chip labeled “Save task” in a task management app._

Multiple chips should appear together in a set, whereas there should be no more than 3 buttons in a single arrangement.

Chip sets can be scrolled horizontally.

_footer: Chips can be scrolled horizontally_
_altText: Multiple chips in event reminder._

_footer: Don’t display a single chip by itself. Chips should appear in a set._
_altText: Single chip in event reminder._

### Variants

Choose the chip variant based on its purpose and author. 

Does the chip represent an action (assist chip) or filter results (filter chip)? 

Is its content generated by the product (suggestion chip), or by the person using the product (input chip)?

_footer: There are four chip variants:   - Assist   - Filter   - Input   - Suggestion_
_altText: 4 chip variants._

Purpose
 |
Chip variant
 |
Rationale
 |
Example
 |

Action
 |
[Assist chip](/m3/pages/chips/guidelines#5dd1928c-1476-4029-bdc5-fde66fc0dcb1)
 |
Assist chips represent smart or automated actions that can span multiple apps
 |
**Add to calendar** action
 |

Filter
 |
[Filter chip](/m3/pages/chips/guidelines#8d453d50-8d8e-43aa-9ae3-87ed134d2e64)
 |
Filter chips represent filters for a collection
 |
Platform selector on material.io/components
 |

Information, user-authored
 |
[Input chip](/m3/pages/chips/guidelines#4d2d5ef5-3fcd-46e9-99f2-067747b2393f)
 |
Input chips represent discrete pieces of information entered by a person
 |
Gmail contact in the **To** field
 |

Information, product-authored
 |
[Suggestion chip](/m3/pages/chips/guidelines#36d7bb16-a9bf-4cf6-a73d-8e05510d66a7)
 |
Suggestion chips help narrow a person’s intent by presenting dynamically-generated suggestions
 |
Suggested chat response
 |

## Anatomy

_footer: - Container - Label text - Leading icon or image (optional) - Trailing icon (required for input chips, optional for filter chips)_
_altText: Diagram of 4 elements of a chip._

### Container

All chips are slightly rounded with an 8dp corner.

_footer: Chips have rounded corners_
_altText: Diagram of rounded corner of chip container._

**Shadows & elevation**

Chip containers can be elevated if placed on top of an image or dynamic background.

_footer: When on complicated backgrounds, chip containers can be elevated_
_altText: 3 elevated assist chips above image of restaurant photograph._

_footer: Use an outline to define the edge of the chip's container on regular backgrounds_
_altText: 3 variants of chips in an outlined style._

_footer: Chips may use elevation when placed on an image_
_altText: 3 variants of chips in an elevated style above restaurant photograph._

_footer: Chips shouldn't be elevated when placed directly on the page_
_altText: 4 elevated chips above blank background._

_footer: Avoid using elevation to indicate a chip's pressed state. Instead, use the visual ripple effect._
_altText: Elevated chip in pressed state._

### Label text

Chip label text should be 20 characters or fewer, and have the same typography style as buttons.

Chip labels should remain brief for the limited space available. Skip conventional grammar rules, such as articles (take "a" walk), to save space.

_footer: Keep chip labels short_
_altText: Filter chip in maps app labeled “Walking.”_

_footer: Avoid chip labels longer than 20 characters_
_altText: Filter chip in maps app labeled “Walking navigation session."_

### Leading icon or image (optional)

Chips can contain a leading icon, logo, or circular image. Use a system icon to help identify a chip's category.

_footer: Chips can contain a logo, icon, or circular image_
_altText: 2 input chips, 1 with a leading circular avatar and the other with a leading icon._

The leading icon color for unselected chips can be customized through theming. While the default color role is **primary**, the **on surface variant** color role is a good alternative when the icon style requires less emphasis.

_footer: **Primary** color (left) and **on surface variant** color (right)_
_altText: 2 screens of a restaurant page with chips labeled "Add photos" and "Add dishes." The leading icons are purple in 1, grey in the other._

Leading circular images are sized larger than leading icons to provide more space for detail. Icons are designed to be legible at small sizes.

See the [Specs tab](/m3/pages/chips/specs/) for precise measurement values.

_footer: Leading images, such as avatars, are sized larger than leading icons or logos_
_altText: 2 input chips, 1 with a 24dp leading avatar and the other with an 18dp leading icon._

### Trailing icon (optional, input and filter chips only)

The trailing icon is present for input and filter chips.

On input chips, it's required and must be used to remove the chip. On filter chips, it's optional, and can be used to open a menu or remove the chip. 

Secondary actions (such as a trailing icon button for **Remove**) must have a 48x48dp interaction target that doesn’t interfere with the chip's primary action (such as **Edit** or **Drag**). To achieve this, apply a minimum width of 88dp to the chip, or 42dp to the label text.

_footer: Interaction targets for actions like **Edit** or **Close** have a size of 48x48. This can be achieved by setting the minimum container width to 88dp._
_altText: A chip with 88dp min width has 2 touch targets of 48x48dp._

## Assist chips

Assist chips represent smart or automated actions that can span multiple apps, such as opening a calendar event from the home screen. Assist chips function as though the person asked an assistant to complete the action. They should appear dynamically and contextually in a UI.

An alternative to assist chips are buttons, which should appear persistently and consistently.

_footer: The text in most assist chips begins with a short verb, like **Get**or **Add**_
_altText: 2 assist chips labeled “Add to my itinerary” and “12 mins from hotel” on map screen about Los Cantantes._

_footer: An assist chip can surface supplemental information like a calendar event, as well as provide contextual actions_
_altText: 2 assist chips labeled “Event location” and “Chat” on phone lock screen._

_footer: During an interaction, assist chips can transform into modals, transition into full-screen views of new content, or readjust to display more results inline_
_altText: Assist chip transformed into time picker with radio buttons._

Assist chips can trigger an action or show progress and confirmation.

Write assist chips like buttons: start with a verb. Adjust text dynamically if the state changes, like **Save** to **Saved**.

_footer: Tapping an assist chip triggers a contextual action_
_altText: 3 assist chips labeled “Mail,” ”Messenger”, and “Video Chat” on a travel article._

_footer: Assist chips can show progress and confirmation feedback_
_altText: Assist chip showing confirmation upon selection._

Assist chips are displayed after primary content, such as below a card or persistently at the bottom of a screen.

_footer: Assist chips should be shown underneath primary content_
_altText: 3 assist chips labeled “Turn on lights”, “Set alarm”, and "Close Blinds" on Welcome Home screen._

## Filter chips

Filter chips use tags or descriptive words to filter content. They can be a good alternative to segmented buttons or checkboxes when viewing a list or search results.

Tapping on a filter chip activates it and appends a leading checkmark icon to the starting edge of the chip label.

Write filter chips with nouns that describe the category to **include** in the results. Avoid negative phrases like **Exclude images**.

_footer: Filter chips rely on tags or descriptive words to filter content_
_altText: 4 filter chips labeled “Docs” “Slides” “Sheets” and “Images” with “Slides” and “Sheets” selected_

_footer: Filter chips in a shopping app_
_altText: 5 filter chips representing popular electronics categories in a shopping app. The chip “Game consoles” is selected._

_footer: Filter chips in a real estate app_
_altText: 6 filter chips representing apartment amenities in a real estate app. 2 of the chips are selected._

Tap a chip to select it. Multiple chips can be selected or unselected.

_footer: An icon can be added to indicate when a filter chip is selected_
_altText: 6 filter chips representing apartment amenities in a real estate app. 3 selected chips include checkmarks while 3 don’t._

_footer: Filter chip suggestions can dynamically change as a person starts to select filters_
_altText: 3 amenities chips are selected, and 2 neighborhoods._

Alternatively, a single chip can be selected. This offers an alternative to segmented buttons, radio buttons, or single select menus.

However, avoid mixing chip set behaviors. All chip sets on a page should be either single-select or multi-select.

_footer: Filter chips can be set so that selecting a single chip automatically deselects all other chips in the set_
_altText: filter chips labeled “Extra soft”, “Soft”, “Medium”, and “Hard” First, the “Extra soft” chip is selected, then it unselects as the “Medium” chip is selected._

In medium and expanded breakpoints, filter chips may contain a trailing icon to directly remove the chip or open a menu of options.

In compact windows, the trailing icon's target area is too small to be accessible on its own. However, if the whole chip can be selected to accomplish the action, the chip is likely still accessible.

_footer: The remove icon helps users remove the filter_
_altText: Filter chip with trailing remove icon._

_footer: Filter chips can open a menu for more filtering options_
_altText: Filter chip with trailing menu icon._

When combined with a menu, the filter chip opens a list of selectable options.

_footer: In compact windows, make sure the whole chip opens the menu. Otherwise, the target area is likely too small to be accessible._
_altText: In a trail selector mobile app, a person selects the whole chip to change the menu selection from Walking to Cycling._

Filter chips can be used with other components, such as search fields and sheets.

_footer: Filter chips can be shown underneath a search field_
_altText: 4 filter chips below search field_

_footer: Use a side sheet to organize many filter chips_
_altText: Filter chips used as tags in a side sheet on a file application._

_footer: Filter chips can wrap to a new row. If there are more than two rows, consider using horizontal scrolling to access them all._
_altText: 6 filter chips wrapping to 2 rows_

_footer: Filter chips can scroll horizontally to show many options_
_altText: 4 filter chips with right-most chip partly offscreen, indicating the chips are horizontally scrollable_

_footer: Filter chips should not present only a single option_
_altText: Single filter chip option beneath the header “Category”_

## Input chips

Input chips represent discrete pieces of information entered by a person, such as Gmail contacts or filter options within a search field.

They enable user input and verify that input by converting text into chips.

_footer: Input chips transform text based on a person's input_
_altText: Contacts transformed into 2 input chips in a draft event invite_

Input chips can support editing to change their contents, such as correcting an email address. In edit mode, the chip reverts back to a text string. Editing can be triggered by interacting with the chip, either by selecting it or by a second interaction after selection.

_footer: Input chips converted from email addresses are editable_
_altText: Contact transformed into input chip in the “To” filed of an email draft._

_footer: Using the backspace key with the cursor before a chip selects the entire chip. The chip can then be deleted when the user taps the backspace key again._
_altText: Animation showing selection of chip with backspace key._

A single field can contain multiple input chips. These chips can be reordered or moved into other fields.

_footer: Multiple input chips in one field_
_altText: 2 input chips in the “To” field of an email draft_

_footer: Input chips being moved from one field to another_
_altText: 1 input chip moved from the “To” field to the “CC” field of an email draft_

Input chips can expand to show more information or options. A container transform transition pattern is used to reveal additional content.

_footer: Input chips can expand_
_altText: Contact input chip expands to show multiple email addresses for that contact_

### Placement

Input chips can be integrated with other components.

They can appear:

- Inline with the cursor in a text field
- In a stacked list
- In a list that can be horizontally scrolled

_footer: Input chips can wrap to a new row if all chips need to be visible_
_altText: 4 input chips wrapping to 2 rows._

_footer: Input chips can scroll horizontally_
_altText: 3 input chips horizontally scrolling._

### Icons & images

The leading icon of input chips can be an icon, logo, or circular image.

_footer: Input chips can contain an icon, logo, or circular image_
_altText: 2 input chips, 1 with leading thumbnail, 1 with leading icon._

The trailing icon is always aligned to the end side of the container. It’s placed:

- On the right for left-to-right (LTR) languages, such as English
- On the left for right-to-left (RTL) languages, such as Farsi

_footer: Input chips can be a more flexible way to filter search results, compared to filter chips_
_altText: 2 input chips with trailing icons following the label text._

_footer: Input chips make it easier to add and remove contacts_
_altText: 3 input chips with trailing icons following the label text._

_footer: Overflowed chips in a text field should follow the same behavior as regular text. An unfocused text field with overflowed content should display the beginning of the input. Tapping the field snaps the user to the end of the input with the cursor and keyboard active._
_altText: Animation of overflowed chips in a text field._

## Suggestion chips

Suggestion chips help narrow a user’s intent by presenting dynamically generated suggestions, such as possible responses or search filters.

Write suggestion chips as nouns or short phrases, depending on context. Avoid exceeding 20 characters when possible.

_footer: The text labels within suggestion chips are most often nouns or short phrases_
_altText: 3 suggestion chips offering ID options in a photo-recognition app._

_footer: Suggestion chips can offer quick-reply options in a chat or email app_
_altText: 3 suggestion chips with automated reply options in a chat app._

_footer: A suggestion chip can help the user start a search_
_altText: 2 suggestion chips with search options “What song is this?” and “What are the lyrics?”_

### Placement

When displaying multiple chips together, place them inline as a row of options, not listed vertically. Overflowing chips should break to the next line. 

If the field is only one row high, chip sets can scroll horizontally instead.

Keep an 8dp minimum space between chips. Chips must also have a minimum 48dp target size, regardless of placement or density. If required, the target can extend beyond the visible container of the chip.

Text labels for chips should be concise. Chip labels will truncate when in a wrapped layout, and when they are wider than the full width of the window.

_footer: - Margins between chips - Margin between each line_
_altText: Diagram of margins between a set of chips._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

- Use a chip to perform an action
- Navigate to a chip
- Activate a chip

## Interaction & style

The chip label needs at least 3:1 contrast with the background.

A chip that performs an action should present the same semantics as a button to a platform's accessibility API.

_footer: High contrast helps differentiate chips clustered together_
_altText: The chip label needs to pass 3:1 contrast._

### Horizontal overflow

When there are too many chips to fit on one row, provide a way to display them all at once and avoid scrolling. 

**Reflow method:**Use a filter chip as a leading element to reflow the horizontal list. This should shift down the content below and make room for all chips to show.

_footer: The **Show all**filter chip is used to reflow the list, displaying all chips at once and pushing down the content below_
_altText: Selecting a leading button pushes chips previously reachable only by scroll below, making them all visible._

**Menu method:**Create a leading button to display all chip options in a menu. Use this option to avoid shifting the position of the content below.

Don’t use the menu method on chips with a second action, like a remove icon.

_footer: The **Show all** leading button shows a menu of chip options, keeping the place of content below_
_altText: Selecting a filter button produces a menu with all previously hidden chips visible._

### Avoid applying density by default

Don't apply density to chips by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

## Keyboard navigation

Keys | Actions |
**Tab** | Moves focus to enabled chip or chip group |
**Space** or **Enter** | Activates, selects, or deselects the focused chip |
**Backspace** or **Delete** | Removes currently focused input chip |
**Arrows** | Moves focus between chips |

## Labeling elements

Element
 |
A11y label
 |
Role (Web)
 |
Role (Android Views (MDC-Android))
 |
Role (Jetpack Compose)
 |

Image / Icon within chip
 |
Hide image
 |
-
 |
-
 |
-
 |

Basic chip (one action)
 |
“{chip content}”
 |
gridcell
 |
button
 |
button
 |

Selectable chip
 |
“{chip content}”
 |
gridcell
 |
radio button
 |
checkbox
 |

Remove icon (no other action)
 |
“Remove {chip content}”
 |
-
 |
-
 |
-
 |

Two actions (e.g., select + remove)
 |
“{chip content}.” Then

“Remove {chip content}”.
 |
button or checkbox
 |
button or checkbox
 |
button or checkbox
 |

The accessibility label for a chip is the chip's label text. Additional actions, like remove, are labeled separately.

_footer: Accessibility tags should include both the label and role_
_altText: Accessibility tags for a chip._

### Multi-select

For multi-select chip sets, **Space** or **Enter** will select the focused chip and allow you to select all of the chips. **Space** or **Enter** will also deselect a focused selected chip.

_footer: While multiple chips can be selected, only one can be in focus_
_altText: Accessibility tags for a multi-select chip._

### Drop-down list

The accessibility label should align with each list item’s text label. 

For list items with text and an icon, the accessibility label should be marked as decorative to avoid redundant verbalizations.

_footer: The accessibility label should be the text label_
_altText: Accessibility tags for a drop-down list chip._

### Input chip remove action

Display the remove icon whenever a chip can be removed. On mobile, if remove is the only chip action, the remove icon isn't necessary. Instead the chip can be removed by selecting it and pressing the **Delete** key on the keyboard.

Each chip is a focusable element. 

- If a chip only has a remove icon, the entire chip and icon are one focusable element.
- If a chip has a second action, like select, then the chip content and remove icon are two separate focusable elements.

_footer: The remove action is focused when the chip can also be selected_
_altText: A focused remove action within a chip._

### Showing chip interactivity

Material requires that chips use a secondary indicator to show that they are interactive in context, allowing users with low vision and cognitive disabilities to see them.

Use one of the following methods: 

-
Add a label before the chip group suggesting interaction, such as **Select type**

_footer: Labels introducing a chip group can indicate that they are selectable_
_altText: Label saying “Select type” above a series of chips, with “Extra soft” selected._

-
Provide interactive page context, such as **Filter results**, indicating chips can be selected to narrow results

_footer: Page context can indicate how search results will be narrowed by selecting chips_
_altText: Page context saying “Filter results” above chips listing different categories._

-
Use the **outline** color role, instead of **outline variant**, to ensure a minimum 3:1 contrast

-
Include an interactive chip label, such as **Turn on lights**, or leading icon

_footer: Chips can show they are interactive with a darker outline color stroke_
_altText: A selectable chip with more pronounced outline stroke._

_footer: Chips can also use a leading icon or label to show interactivity_
_altText: A chip labeled “Turn on lights” with a leading icon related to lights._

---

<!-- Source: m3.material.io · components_search · updated 2026-07-27T04:04:05.736Z · CC-BY 4.0 (Google) -->

## Search



<!-- section: Overview -->

-
Use search for navigating a product with queries

-
A search bar can include a leading search icon, hinted search text, and optional trailing icons

-
Search can display suggested keywords or phrases as a person types

-
A search bar displays search suggestions or results in a list

-
Use a search app bar to provide an emphasized, global entry-point

_footer: When inputting text, search suggestions or results appear below the search bar_
_altText: Mobile UI shows a person typing into an email search bar. It expands to show a list of results._

## Availability & resources

## M3 Expressive update

Search has a new visual style, motion, and more flexibility for trailing icons. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

**February 2025** 

Naming

-
Search bar and search view are now collectively named **search**

Configurations

-
Styles: Search can be contained (recommended) or divided

-
Gaps can separate results into groups

Motion

-
The search bar grows wider when focused

Supported platforms:

-
[Jetpack Compose](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#SearchBar(androidx.compose.material3.SearchBarState,kotlin.Function0,androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Shape,androidx.compose.material3.SearchBarColors,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp))

_footer: The **contained** search style features a persistent, filled search container_
_altText: A recipe search with “Search recipes” hinted text, “Mexican dishes” is entered, then results appear in a list._

## Differences from M2 to M3 baseline

-
Color: New color mappings and compatibility with dynamic color

-
Elevation: Lower elevation and no shadow by default

-
Name: Search was formerly known as open search bar

-
Variants: Two official variants of search components: search bar and search view

_footer: M2 open search bars were square and elevated_
_altText: M2 open search bar._

_footer: M3 search bars are rounded, use tonal surface, and support dynamic color_
_altText: M3 search bar._

<!-- section: Specs -->

## Variants

_footer: When a person executes a **search**, results appear in a list below the search bar_
_altText: Typing “Ping” into a search bar reveals a list of email results._

Variant
 |
M3
 |
M3 Expressive
 |

Search
 |
Available
 |
Available
 |

## Configurations

### Style

Search comes in two styles:

-
Contained: Has an expressive look and feel. It uses a filled container to separate a search bar from a list of suggestions or results

-
Divided (baseline): Doesn’t have the latest visual style, motion, or flexibility

_footer: The contained style has a persistent, filled container, expressive motion, and rounded shape_
_altText: An email inbox search bar in a contained style._

_footer: The divided (baseline) style uses a divider to separate the search bar from suggestions and results_
_altText: An email inbox search bar in a divided style._

### Layout

Search suggestions and results appear in customizable lists, with two layout options: full-screen and docked. [More on search layouts](/m3/pages/search/guidelines#4f6c921c-795f-4e06-9b12-27ae7d502adb)

_footer: Full-screen layout in the contained style_
_altText: Full-screen search results with a search bar in the contained style._

_footer: Docked layout in the contained style_
_altText: Docked search results with a search bar in the contained style._

_footer: Full-screen layout in the divided style_
_altText: Full-screen search results with a search bar in the divided style._

_footer: Docked layout in the divided style_
_altText: Docked search results with a search bar in the divided style._

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Style
 |
Contained
 |
--
 |
Available
 |
 |
Divided
 |
Available
 |
Not recommended. Use contained.
 |

Layout
 |
Docked, full-screen
 |
Available
 |
Available
 |

## Tokens & specs

Use the table's menu to select a token set. The **search bar** set only contains tokens for the unfocused search bar. The **search view** set contains all other tokens when interacting with search, including all styles and layouts. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Anatomy

Search includes a search bar and a container for suggestions and results. The container is empty by default. Use the list component to add content. In the divided (baseline) style, a divider separates the search bar and results.

_footer: - Search bar container  - Leading icon  - Supporting text  - Trailing icon and avatar (optional)  - Input text  - Container for search suggestions or results_
_altText: 6 elements of search._

### Examples

-
With avatar

-
With one trailing icon button

-
With two trailing icon buttons

-
With trailing icon button and avatar

_altText: 4 search bars with different trailing elements._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.

### Full-screen layout

_footer: Full-screen search color roles used in light and dark themes:  - Surface container low  - On surface variant  - On surface variant  - Surface container high  - On surface variant  - On surface_
_altText: 6 full-screen search color roles in light and dark themes._

### Docked layout

_footer: Docked search color roles used in light and dark themes:  - Surface container high  - On surface variant  - On surface variant  - Surface container high  - On surface variant  - On surface_
_altText: 6 docked search color roles in light and dark themes._

## States

States are visual representations used to communicate the status of a component or an interactive element. In [focused search](/m3/pages/search/guidelines#a9b2df31-8561-4326-82cd-41ed6532b765), individual elements maintain their own interaction states. [Learn more about interaction states](/m3/pages/interaction-states/overview)

### Search bar

_footer: - Enabled  - Hovered  - Focused  - Pressed (ripple)_
_altText: 4 search bar states in light and dark mode._

### Search suggestions & results

Search includes a container for suggestions and results. The container is empty by default. Use the list component to add content.

_footer: - Enabled  - Hovered  - Focused  - Pressed (ripple)_
_altText: 4 search result states in light and dark mode._

## Measurements

### Search bar

_footer: Unfocused search bar with leading and trailing icon measurements_
_altText: Search bar with leading and trailing icon size and padding measurements._

_footer: Unfocused search bar with avatar measurements_
_altText: Search bar with trailing avatar size and padding measurements._

In M3 Expressive, the search bar expands when focused. The margins change from 24dp to 12dp.

_footer: Unfocused search bar margin measurements_
_altText: Unfocused search bar margins of 24dp._

_footer: Focused search bar margin measurements_
_altText: Focused search bar margins of 12dp._

Element
 |
Attribute
 |
Value
 |

Container
 |
Width
 |
Min: 360dp, max: 720dp
 |

Height
 |
56dp
 |

Label alignment
 |
Start-aligned
 |

Leading padding
 |
Unfocused: 24dp, focused: 12dp
 |

Trailing padding
 |
Unfocused: 24dp, focused: 12dp
 |

Leading icon and label padding (from tap target)
 |
4dp
 |

Label and trailing icon padding (from tap target)
 |
4dp
 |

Avatar
 |
Size
 |
30dp
 |

### Focused search

#### Contained style

_footer: Full-screen search padding and size measurements for contained style_
_altText: Full-screen layout size and padding measurements in contained style._

_footer: Docked search padding and size measurements for contained style_
_altText: Docked layout size and padding measurements in contained style._

Element
 |
Attribute
 |
Value
 |

Full-screen container
 |
Width
 |
Full width
 |

Height
 |
Full height
 |

Docked container
 |
Width
 |
Min: 360dp, max: 720dp
 |

Height
 |
Min: 240dp, max: 2/3 of screen height
 |

Search bar container
 |
Height
 |
56dp
 |

Label alignment
 |
Start-aligned
 |

Leading padding
 |
16dp
 |

Trailing padding
 |
16dp
 |

Leading icon and label padding (from tap target)
 |
4dp
 |

Leading icon and label padding (from tap target)
 |
4dp
 |

#### Divided style

_footer: Full-screen search padding and size measurements for divided style_
_altText: Full-screen layout size and padding measurements in divided style._

_footer: Docked search padding and size measurements for divided style_
_altText: Docked layout size and padding measurements in divided style._

<!-- section: Guidelines -->

_footer: When focused, a search bar can show a list of search suggestions. As text is entered, search results appear._
_altText: A mobile UI search with hinted text “Search recipes”, “Mexican dishes” is entered, and a list of recipe results appear._

## Usage

Search helps people find information quickly.

Use search for products with many items to manage, such as files or messages.

_footer: Search helps people find information in large inboxes like messages or emails_
_altText: Mobile UI shows a search bar at the top of a message inbox._

### Different ways to search

The search entry point is dependent on a product’s needs, and should be easy to find:

-
Search bar: Use to search contents in a specific view, like **Search your messages**

-
Search app bar: Use this app bar variant when search is the primary, global function

-
Search icon button: Use when search is a secondary action or not the main focus

_footer: Add a **search bar** below a title to search specific content_
_altText: A mobile app with a search bar below the page title._

_footer: For global search, use a persistent **search app bar**, integrated into an app bar_
_altText: A mobile app with a search app bar._

_footer: Use a **search** **icon button** when search is a secondary action_
_altText: A mobile app with a magnifying glass icon on the leading side of the app bar._

### Focused search

When a search entry point is selected, it opens focused search.  

-
Search suggestions can appear before text is entered

-
Search results can show as someone is typing or after a search is executed

-
Individual elements maintain their own interaction states when search is focused

[More on search states](/m3/pages/search/specs#65c58b10-4569-43d6-9c11-64a5b02f3099)

_footer: When focused, a search bar expands to show search suggestions or results in a list_
_altText: Focused search with a list of suggestions on a mobile screen._

If search is the primary action, focused search can be a standalone destination reached from a navigation bar.

_footer: Focused search can be a standalone destination, reached by selecting an item in a navigation bar_
_altText: Focused search on a mobile screen with a list of suggested contacts._

### Search suggestions & results

Search suggestions and results both appear in a list component by default.

To help people find information quickly, consider adding variety and context, such as:

-
Leading icons related to suggestions

-
Category labels, like **Recent**, **Contacts**, or **Suggestions**

-
Avatars or other high-priority items

-
Filter chips to narrow down results

_footer: Include high-priority items like avatars in search suggestions or results_
_altText: Search with suggestions organized in a column, ending with a row of 5 contact avatars with names._

### Gaps

Use gaps to separate a list of suggestions or results into groups.

[More on using gaps in lists](/m3/pages/lists/guidelines#9e96fd72-5bf3-49df-9baf-e025dcca344d)

_footer: To separate list items into distinct groups, use a gap_
_altText: A gap separates the location and calendar list items from people and pets avatars._

## Placement

A search bar is typically placed at the top of a screen to remain prominent and accessible. Its location depends on whether search is the primary focus of a product or a secondary action.

_footer: A search bar can be the primary focus of a page_
_altText: Mobile UI with a search bar directly below a Settings headline._

_footer: Search bars should usually be placed at the top of the content_
_altText: Mobile UI with a search bar centered at the top of the screen, above a row of Favorites avatars._

_footer: Search can be a secondary action_
_altText: A photos app with a search icon._

### Focused search layouts

When focused, search suggestions and results appear in a list below the search bar.  

There are two layout options:

-
**Docked** opens a list below the search bar, with a scrim covering main content

-
**Full-screen** expands to fill the screen

[More on adaptive design](/m3/pages/search/guidelines#eb45ccc4-d1b5-4ea1-bee5-ea1c3d1c5436)

_footer: Docked layout on a tablet_
_altText: Tablet UI shows a list of search results docked below the search bar._

_footer: Full-screen layout on mobile_
_altText: Mobile UI shows a list of search results filling the screen._

## Anatomy

_footer: - Search bar container  - Leading icon  - Supporting text  - Avatar or trailing icon (optional)  - Input text  - Container for search suggestions or results_
_altText: 6 elements of search._

### Search bar container

In the contained style, the search bar container remains the same shape in both the unfocused and focused states. Avoid changing the container behavior.

The container’s margins should be:

-
Unfocused: 24dp

-
Focused: 12dp

In the divided (baseline) style, a divider separates the search bar and results.

_footer: Search bar containers have persistent, rounded corners_
_altText: Side-by-side comparison of a search container in unfocused and focused states._

#### Container color

Search bars use the **surface container high** color role. This role applies when the screen background is white or a tonal **surface** color, ensuring the container has clear contrast.

_footer: Search bars use **surface container high** to provide clear contrast_
_altText: 2 mobile UIs show search bars on white and tonal backgrounds._

Avoid using a **surface container high** color on a **surface container** background. This can cause the search bar to blend in, making it difficult for people to find.

To ensure proper contrast, use surface container roles that are more than one step apart.

_footer: Using a **surface container high** color on a **surface container** background reduces contrast and may affect accessibility_
_altText: A “surface container high” search bar on a “surface container” background._

### Icons & icon buttons

#### Leading icons

The leading side of a search bar should include either:

-
A navigational icon button, such as a menu or arrow

-
A non-functional search icon

_footer: A search bar can contain a non-functional search icon_
_altText: A search bar on a tablet screen contains a non-functional search icon and a trailing avatar._

#### Trailing icons

A search bar should have one or two trailing icons or icon buttons.

Trailing actions can include:

-
Additional modes of searching like voice search

-
A separate high-level action such as current location or profile

-
An overflow menu

-
A decorative search icon

_footer: Use a maximum of two trailing icons_
_altText: A search bar with 2 trailing icon buttons: a microphone and an overflow menu._

_footer: Combine an avatar with up to one other trailing icon button_
_altText: A search bar with a trailing microphone icon and avatar._

_footer: Focused search can show an optional **clear** icon to remove input text_
_altText: Focused search with a trailing x icon to clear input text._

### Text

#### Hinted search text

Provide a short description of the information people can search, like **Search replies** or **Search your messages**.

#### Input text

When a person starts typing, the hinted text is replaced with the input text.

_footer: Hinted search text is replaced when a search query is entered_
_altText: A search bar labeled “Search replies”. “Peanut is entered and “Quick results” appear._

## Adaptive design

The search bar position and alignment should scale with the layout, and stay close to the searchable content.

In most cases, a search bar should:

-
Stay in its pane and scale in width accordingly

-
Internal elements anchor to the left and right as the parent container scales

[More on applying layout](/m3/pages/layout-overview/)

_footer: Keep the search bar close to the content a person can search_
_altText: A search bar keeps its layout region and scales with different window sizes and layouts._

### Focused search

When focused, search can switch between showing suggestions or results in a:

-
**Docked layout**: Best for medium and expanded windows

-
**Full-screen layout**: Default for compact breakpoints

[More on search layouts](/m3/pages/search/specs#fc12e839-f356-4f48-9bd5-0ed210565bfe)

_footer: - A docked layout on a large screen  - A full-screen layout, the default for compact screens_
_altText: Search suggestions in docked and full screen layouts._

Search suggestions or results should swap from full-screen in compact windows to docked in larger breakpoints.

_footer: Search suggestions and results should adapt to fit different window sizes_
_altText: Animation shows search suggestions adapting from full-screen on mobile to a docked layout as the window size increases._

## Behavior

### Focused search

When a search bar is selected, search becomes focused and can:

-
Show historical suggestions before typing

-
Show suggestions or results as someone is typing

-
Wait to show suggestions or results until a search is queried 

The **back** icon releases focus, dismisses any suggestions or results, and returns the search bar to its original state.

_footer: When focused, a list of search suggestions can appear_
_altText: When a search bar is tapped, it becomes focused, and suggestions appear in a list._

_footer: Focus is released when the back icon is selected_
_altText: A person searches a photo app. The back icon returns the search bar to its original state._

### Scroll

Depending on needs, a search bar can:

-
Scroll away with content, then reappear when a person begins scrolling up

-
Remain fixed at the top of the screen

_footer: A search bar can scroll up with content, then reappear when a person scrolls down_
_altText: Scrolling up hides the search bar. It reappears when scrolling down._

### Search results

To execute a search, a person can:

-
Type a query and press **Enter**

-
Select a suggestion or result without querying a search

Search results appear in a list below the bar, and scroll beneath the bar.   

For accessibility, focused search needs a clear status indicator that it’s searching content, like a search icon or **Results** label. [More on search accessibility](/m3/pages/search/accessibility/)

_footer: Show search results in a compact, organized list, with an indicator like **Quick results**_
_altText: “Peanut” is the entered search query and the first suggestion in the list._

When search results are queried, the input text should remain visible, but not in focus.

_footer: Search suggestions and results display in a list, and the input text remains visible_
_altText: “Pla” is entered into the search bar, “Plants” is suggested and selected._

### Predictive back

On Android, [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows a person to swipe left or right on search. 

-
Search detaches from the screen edge to signal the full-screen layout will minimize

-
The previous screen is revealed in a preview

[More predictive back design guidance](https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture)

_footer: The search surface and content scale back in the direction of the gesture_
_altText: Swiping left on search causes the Android screen to scale left._

<!-- section: Accessibility -->

## Use cases

People should be able to use assistive technology to:

-
Navigate to and focus on a search bar

-
View the hinted search text or persistent label

-
Input text and complete a search

-
Interact with a list of search suggestions and results

-
Clear the input text

## Interaction & style

### Autosuggest

When search suggestions and results appear, the screen reader must announce the change. This lets people know list items are available for selection.

_footer: Autocomplete results should be announced by the screen reader_
_altText: Hinted search text and autocomplete results on a mobile screen._

## Initial focus

Initial focus lands on the first interactive element. This is often a leading icon button or text field. A leading icon button usually activates search directly or opens a navigation component.

_footer: Initial focus can land on a leading icon_
_altText: Search bar with a focused leading icon._

_footer: If there’s no leading icon, focus lands on the text field_
_altText: Search bar with no leading icon. The text field is focused._

## Keyboard navigation

**Keys**
 |
**Actions**
 |

**Tab** or **Shift** + **Tab**
 |
Navigate between interactive elements
 |

**Space** or **Enter**
 |
Activate the search text field for input
 |

**Arrows**
 |
Navigate between search result items
 |

## Labeling elements

The hinted search text should be used as the accessibility label describing the search bar.  

The role for the input field should be:

-
Android: **Text field**

-
iOS: **Search field**

_footer: The accessibility label should match the hinted search text_
_altText: Search bar with “Label: Search messages” and “Role: Text field”._

Leading and trailing icon buttons should be labeled according to their [accessibility guidance](/m3/pages/icon-buttons/accessibility).

_footer: Use icon labels for icon buttons_
_altText: A search bar with accessibility labels for its leading icon button and trailing avatar._

Search suggestions and results use the list component. Screen readers automatically announce the results as a list.

For accessibility labels, follow the [list accessibility guidelines](/m3/pages/lists/accessibility).

_footer: Search suggestions and results are created using lists_
_altText: A search bar on mobile, showing search results in a list._

---

<!-- Source: m3.material.io · components_date-pickers · updated 2026-07-27T14:12:27.562Z · CC-BY 4.0 (Google) -->

## Date pickers



<!-- section: Overview -->

-
Date pickers can display past, present, or future dates

-
Three variants: docked, modal, modal input

-
Clearly indicate important dates, such as current and selected days

-
Follow common patterns, like a calendar view

_footer: - Docked date picker - Modal date picker - Modal date input_
_altText: 3 variants of date pickers side-by-side. The docked date picker has an outlined text field above a calendar view. The modal date picker allows people to select a date from a calendar view. The modal date input lets someone type in a date._

## Availability & resources

## Differences from M2

-
Typography and spacing: Titles and labels are larger and have increased spacing to accommodate 48dp target size

-
Color: New color mappings and compatibility with dynamic color

-
Variants: The three variants of date pickers have been renamed to not be device-dependent. The former desktop date picker is now known as the docked date picker. The former mobile date picker and date input are now known as modal date picker and modal date input to reinforce that the user must take an action.

_footer: M2: Date pickers had a drop shadow and different color mappings_
_altText: Old version of a date picker with a white background and shadows._

_footer: M3: Date pickers have larger typography, no shadow, and new color mappings compatible with dynamic color_
_altText: New version of date picker with a colorful background, rounded corners, and no shadows._

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and their values.

## Docked date picker

_footer: - Outlined text field - Menu button: Month selection - Menu button: Year selection - Icon button - Weekdays label text - Unselected date - Today’s date - Outside month date - Text buttons - Selected date - Container_
_altText: Diagram indicating the 11 elements of a docked date picker._

_footer: - Outlined text field - Menu button: Month selection (pressed) - Menu button: Year selection (disabled) - Header - Menu - Selected list item - Unselected menu list item - Container_
_altText: Diagram indicating 8 elements of a docked date picker with an open dropdown menu showing the months May to November._

### Docked date picker color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Docked date picker color roles used for light and dark themes:  - Primary - On surface variant - On surface variant - On surface - On surface - Primary - On surface variant - Primary - Surface container high - Primary - On primary_
_altText: 11 color roles of a docked date picker in light and dark themes._

_footer: Docked date picker menu color roles used for light and dark themes:  - Primary - On surface variant - On surface - Outline variant - Surface container high - Surface variant - On surface_
_altText: 7 color roles of a docked date picker menu in light and dark themes._

### Docked date picker measurements

_footer: Docked date picker padding and size measurements_
_altText: Diagram of padding, size, and layout measurements._

_footer: Docked date picker month menu padding and size measurements_
_altText: Diagram of padding, size, and layout measurements._

### Docked date picker configurations

_footer: - Day selection - Month selection - Year selection_
_altText: 3 configurations of docked date picker._

## Modal date picker

_footer: - Headline - Supporting text - Header - Container - Icon button - Icon buttons - Weekdays - Today’s date - Unselected date - Text buttons - Selected date - Menu button - Divider_
_altText: Diagram indicating the 13 elements of a modal date picker in the day selection view._

_footer: - Headline - Supporting text - Header - Container - Icon button - Unselected year - Selected year - Text buttons - Divider - Menu button_
_altText: 10 elements of a modal date picker menu._

_footer: - Headline - Supporting text - Icon button - Header - Text button - Icon button - Weekdays label text - Container - Today’s date - Unselected date - In-range active indicator - In-range date - Month subhead - Selected date - Divider_
_altText: Diagram indicating the 15 elements of a modal date picker when selecting a range of dates._

### Modal date picker color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Modal date picker color roles used for light and dark themes in a day selection menu:  - On surface - On surface variant - Surface container high - On surface variant - On surface variant - On surface - Primary - On surface - Primary - Primary - On surface variant - Outline variant_
_altText: 12 color roles of a modal date picker day selection view._

_footer: Modal date picker color roles used for light and dark themes in a year selection menu:  - On surface - On surface variant - Surface container high - On surface variant - On surface variant - Primary - Primary - Outline variant - On surface variant_
_altText: Diagram of 9 color roles of a modal date picker year selection view._

_footer: Modal date picker range selector color roles used for light and dark themes:  - On surface - On surface variant - On surface variant - Surface container high - Primary - On surface variant - On surface - Primary - On surface - Secondary container  - On secondary container  - Outline variant - On surface variant - Primary_
_altText: Diagram of 14 color roles of a modal date picker when selecting a range of dates._

### Modal date picker measurements

_footer: Modal date picker padding and size measurements_
_altText: Diagram of size and padding measurements in day selection view._

_footer: Modal date picker year selector padding and size measurements_
_altText: Diagram of size and padding measurements in year selection view._

_footer: Modal date picker date range selector padding and size measurements_
_altText: Diagram of size and padding measurements when selecting a range of dates._

### Modal date picker configurations

_footer: - Single date selection - Date range selection - Year selection_
_altText: 3 configurations of a modal date picker shown in dark mode._

## Modal date input

_footer: - Headline - Supporting text - Header - Container - Icon button - Outlined text field - Text buttons - Divider_
_altText: Diagram indicating the 8 elements of a modal date input._

### Modal date input color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview/)

_footer: Modal date input color roles used for light and dark themes:  - On surface - On surface variant - Surface container high - On surface variant - Primary - Primary - Outline variant_
_altText: Diagram indicating the 7 color roles of a modal date input._

### Modal date input measurements

_footer: Modal date input padding and size measurements_
_altText: Diagram of the padding and size measurements of a modal date input._

### Modal date input configurations

_footer: - Single date input - Date range input_
_altText: 2 configurations of modal date input._

## Element states

_footer: States for date and year selection:   - Default (enabled) - Disabled - Hovered - Focused - Pressed (ripple)_
_altText: Diagram of 5 various states for date and year elements within date pickers._

<!-- section: Guidelines -->

_footer: Docked date picker on desktop_
_altText: A date picker opens in a form UI._

## Usage

Date pickers let people select a date or range of dates. They should be suitable for the context in which they appear.

Date pickers can be embedded into:

-
Dialogs on compact [breakpoints](/m3/pages/breakpoints) like mobile

-
Text field drop-downs on medium and expanded breakpoints like tablet and desktop

_footer: - Date picker dialog on mobile - Date picker text field dropdown on desktop_
_altText: 2 date picker variations: a dialog on mobile and a dropdown within a text field on desktop._

There are three variants of date pickers:

-
Docked date picker

-
Modal date picker

-
Modal date input

_footer: 1. Docked date picker_
_altText: A docked date picker component._

_footer: 2. Modal date picker_
_altText: A modal date picker component._

_footer: 3. Modal date input_
_altText: A modal date input component._

## Anatomy

### Docked date picker

_footer: - Text field - Menu button - Icon button - Label text - Menu - Text buttons - Container_
_altText: 7 elements of a docked date picker._

_footer: 1. Text field  2. Menu button  3. Menu_
_altText: 3 elements of a docked date picker._

### Modal date picker

_footer: - Headline - Supporting text - Container - Icon button - Previous/next month buttons - Day of week labels - Today’s date - Unselected date - Text buttons - Selected date - Menu button - Divider_
_altText: 12 elements of a modal date picker._

_footer: - Headline - Supporting text - Container - Icon button - Unselected year - Selected year - Text buttons - Divider - Menu button_
_altText: 9 elements of a modal date picker._

### Modal date input

_footer: 1. Headline  2. Supporting text 3. Container 4. Icon button 5. Date input 6. Text buttons 7. Divider_
_altText: 7 elements of a modal date input._

### Full-screen date picker

_footer: 1. Headline 2. Supporting text 3. Icon button 4. Container 5. Text button 6. Icon button 7. Divider 8. Day of week labels 9. Today’s date  10. Selected date range  11. Unselected date  12. Text buttons 13. Selected date range start date  14. Month label_
_altText: 14 elements of a full-screen date picker._

## Docked date picker

### Usage

Docked date pickers allow the selection of a specific date and year. The docked date picker displays a date input field by default, and a dropdown calendar appears when the user taps on the input field. Either form of date entry can be interacted with.

Docked date pickers are ideal for navigating dates in both the near future or past and the distant future or past, as they provide multiple ways to select dates.

_footer: Docked date picker on desktop_
_altText: Docked date picker on a desktop screen._

### Behavior

Dates can be added by using a keyboard or by navigating the calendar UI; both options are immediately available when the docked date picker is accessed.

_footer: Docked date picker_
_altText: Docked date picker with a text field and the UI picker showing the selected date._

_footer: Docked date pickers adjust size dynamically_
_altText: Animation of a docked date picker adjusting its size to the selected month._

_footer: The year selection menu replaces the calendar view_
_altText: Animation of a docked date picker changing from calendar view to year selection menu view._

### Month selection

Month selection can be navigated with the corresponding back and next arrows or by tapping the dropdown menu.

_footer: Docked date picker month selection_
_altText: Docked date picker with a list of months May through September. August is selected._

### Year selection

Year selection can be navigated with the corresponding back and next arrows or by tapping the dropdown menu.

_footer: Docked date picker year selection_
_altText: Docked date picker with a list of years 2025 to 2029. 2025 is selected._

## Modal date picker

### Behavior

Modal date pickers navigate across dates in several ways:

- To navigate across months, swipe horizontally
- To navigate across years, scroll vertically
- To access the year picker, tap the year

Don’t use a modal date picker to prompt for dates in the distant past or future, such as a date of birth. In these cases, use a modal input picker or a docked date picker instead.

_footer: To navigate across months, swipe horizontally_
_altText: Animation of a docked date picker being swiped horizontally to navigate across months._

_footer: To navigate across years, tap the year picker and scroll vertically_
_altText: Animation of a year picker in a docked date picker being tapped and scrolled vertically to navigate across years._

### Date range selection

Date range selection provides a start and end date. Common use cases include:

- Booking a flight
- Reserving a hotel

Modal date pickers navigate across date ranges in several ways:

- To select a range of dates, tap the start and end dates on the calendar
- To navigate across months, scroll vertically

_footer: Modal date range picker_
_altText: Animation of a date range being selected on a modal date range picker._

_footer: Modal date range picker with vertical scroll_
_altText: Animation of a modal date range picker being scrolled vertically to navigate across months._

## Modal date input

### Usage

Modal date inputs allow the manual entry of dates using the numbers on a keyboard. People can input a date or a range of dates in a dialog.

_footer: Modal date with manual input_
_altText: A modal date input component._

_footer: For dates that don’t require a calendar view, the modal date input can be the default view_
_altText: A modal date input component showing a day in 1979, which would be difficult to choose using UI._

_footer: Alternatively, a text field with appropriate hint text can prompt for dates, such as in a form_
_altText: A modal date input with hint text for entering the date._

### Behavior

You can swap between the modal date picker and modal date input using the edit or calendar icon.

_footer: Switching from a modal date picker to a mobile date input for selecting ranges_
_altText: Animation of a modal date picker switching to a modal date input when the range selection icon is tapped._

_footer: Switching from a modal date picker to a modal date input for selecting a single date_
_altText: Animation of a modal date picker switching to a modal date input when the edit icon is tapped._

### Compact breakpoint

On compact [breakpoints](/m3/pages/breakpoints/overview), such as mobile, a full-screen modal date picker is recommended to increase readability and touch target size. It can cover the entire screen.

_footer: A full-screen modal date picker on mobile_
_altText: A full-screen view of modal date picker on a mobile device._

### Medium and expanded breakpoints

The docked date picker works best for medium and expanded breakpoints. It displays a date input field by default, and a dropdown calendar appears when a person taps on the input field. A person can interact with either form of date entry.

Docked date pickers are ideal for navigating dates in both the near future or past, and in the distant future or past, as they provide multiple ways to select dates.

_footer: A docked date picker with a full calendar view is best used on larger devices_
_altText: A docked date picker displaying a full calendar view on a large screen device._

### Selection

Selection is indicated through color, drawing visual attention. In date ranges, start and end dates are selected, while dates in-between appear connected with a subtle highlight.

_footer: Differences between selected the selected date range (August 17–23) and today's date (August 5) are shown through color and fill_
_altText: Animation of a modal date range picker showing visual differences between selecting a date range and today's date._

### Appearing and disappearing

Like other kinds of dialogs, modal date pickers use an enter and exit transition pattern to appear on the screen.

To exit a date picker, the input can either be confirmed (**OK**) or dismissed (**Cancel**). Interacting outside of the dialog will also dismiss the time picker. Unless one of these actions is taken, a time picker will continue to retain focus. Mobile full-screen pickers also have an additional close affordance (x) icon button and **Save** confirmation.

Docked date pickers appear just below the input field.

_footer: Modal date pickers can be dismissed through interacting with content outside the dialog, or with the action buttons in the lower right_
_altText: Animation of a modal date picker's enter and exit transition._

_footer: Interacting with the input for a docked date picker makes the calendar view appear below_
_altText: Animation of a docked date picker's calendar icon being clicked making the calendar view appear for date selection._

### Responsive layout

The sizing of the docked and modal date picker components don’t scale responsively to different breakpoints.

_footer: Don’t scale the date picker responsively to a larger size_
_altText: Docked date picker enlarged on a large screen responsively._

<!-- section: Accessibility -->

## Use cases

People should be able to:

- Enter dates manually by inputting text, without using the picker
- Use multiple input methods, making it accessible to those using assistive technology

On the docked date picker, the text field can be used for input.
On the modal date picker, the date input option should be available using the edit icon.

## Interaction & style

The edit icon indicates the ability to switch to the modal date input.

Interactive targets for all elements meet Material's 48x48dp minimum touch target requirement. Increasing density would negatively impact accessibility by limiting tappable/clickable targets.

_footer: The edit icon indicates the ability to switch to the modal date input_
_altText: Date picker with the edit icon focused._

_footer: Touch targets are 48x48dp_
_altText: Touch target used to select September 17 to 23 on a date picker._

## Date entry methods

The date entry component offers two ways to enter a date:

- Direct text entry into a text field
- Through the date picker

The calendar icon is the exclusive entry point for the date picker.

This improves efficiency for a screen reader and other keyboard users, as it makes interaction with the date picker optional and reduces the amount of key presses required to input a date.

Each input is a separate tab stop, which improves discoverability of the control.

_footer: Entering a date either through direct text entry or the date picker_
_altText: Text input field next to a date picker icon provides a choice of how to enter the date._

## Accessible date input

Automatically format the date after the user hits “Enter“ or navigates out of the text field. Don't automatically format the date by adding slashes or other special characters while the user is typing (also known as input masks). This can cause confusion for people using screen readers because it changes what they typed.  

To reduce errors, accept a range of formats including dashes, spaces, slashes, dots, and 0 to the left of a single digit month/day. This is especially helpful for assistive technology users who might be more prone to errors when interacting with complex inputs.

_footer: The text field's logic can adapt to the user's actual input format, applying the correct formatting after the user has completed their text entry_
_altText: Numeric entry 08172323 automatically formatted to 08/17/2023._

## Optional **Clear** button

If it's not needed for your use case, remove the **Clear** button from the screen to reduce the number of tab stops for keyboard users.

_footer: Remove non-critical actions to reduce the number of tab stops for keyboard users_
_altText: Optional clear button on lower left corner of a date picker._

## Affordance for keyboard shortcuts

Ensure keyboard shortcuts are readily available for keyboard and screen reader users by providing the shortcut key in the tooltip. It should be included in the hint description to be read out by the screen reader.

As shown here, the previous year button is interactive and can therefore be focused via the keyboard. Upon focus, the tooltip explains the behavior of the button and shows the shortcut key.

_footer: Keyboard tooltip example for date picker_
_altText: Shift + Page up is the keyboard shortcut to go to the previous year on a date picker._

## Truncated labels & tooltips

Truncating labels isn't ideal, but tooltips allow the full text to be shown on hover or keyboard focus.

Days of the week are not interactive and are therefore not focusable via keyboard, yet the tooltip is available on hover. The date picker relies on the conventionality of these abbreviations for some assistive technology users.

_footer: Days of the week are not navigable via keyboard, so the tooltip is shown only on pointer hover_
_altText: A pointer hover over the “T” day on a date picker produces the tooltip “Tuesday.”_

## Color contrast between dates

Dates should have contrast of at least 4.5:1 between the link text colors and the background.

_footer: Dates pass the 4.5:1 contrast minimum_
_altText: A date picker’s label text passes the color contrast minimum of 4.5:1._

## Keyboard navigation

**Keys** | **Actions** |
Enter/return | Enter/return |
Enter/return | Closes the calendar and saves the selected date |
Page up/down | Move to the same date on next/previous month |
Home/End     | Move to the first day of the month |
Shift + Page up/down | Moves to the same date in the next/previous year |
Shift + M | Moves to the month list dropdown |
Shift + Y | Moves to the year list dropdown |

## Labeling elements

The text field's accessibility label should clearly state the purpose of the input (for example, event date or reservation date) and should match the placeholder text when the field is empty.

The helper text (below the text field) should specify the date format (for example, MM/DD/YYYY or YYYY/MM/DD) and act as a description for the text field. The default helper text is "MM/DD/YYYY," but this can be customized.

_footer: The accessibility label clearly states the kind of input as an event date_
_altText: Text field accessibility labels._

**Element** | **A11y label** | **Role** |
Previous / next month and year | “{label}” | Button |
Month and year dropdowns | “{label}” | Button |
Days of the week | Column header |  |
Month grid | Grid |  |

## Screen reader verbalizations

To support screen reader users, labels are used to enumerate the complete date. This allows screen reader users to hear the full context of "Monday, August 17” instead of just part of the date.

_footer: Screen readers will state the full day, month, date, and year instead of just the number 17_
_altText: Current date label providing day, month, and year for screen reader accessibility._

---

<!-- Source: m3.material.io · components_time-pickers · updated 2026-07-17T07:13:07.343Z · CC-BY 4.0 (Google) -->

## Time pickers



<!-- section: Overview -->

-
Time pickers are modal and cover the main content

-
Two variants: dial and input

-
People can select hours, minutes, or periods of time

-
Make sure time can easily be selected by hand on a mobile device

_footer: - Time picker dial - Time picker input_
_altText: Dial time picker dial and input time picker._

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color

_footer: M2: Time pickers had different color mappings_
_altText: Time picker’s old color mappings. The selected hour of 7 and AM text is purple, on a purple background._

_footer: M3: Time pickers have new color mappings compatible with dynamic color_
_altText: Time picker's new color mappings. The selected hour of 7 and AM text is black, with different background colors._

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Anatomy

### Time picker dial

_footer: - Headline - Time selector separator - Container - Period selector container - Period selector label text - Clock dial selector center - Clock dial selector track - Text button - Icon button - Clock dial selector container - Clock dial label text - Clock dial container - Time selector label text - Time selector container_
_altText: Diagram indicating the 14 elements of a time picker dial._

### Time picker input

_footer: - Headline - Time input field seperator - Container - Period selector container - Period selector label text - Text button - Icon button - Time input field supporting text - Time input field label text - Time input field container_
_altText: Diagram indicating the 10 elements of a time picker input._

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

### Time picker dial color

_footer: Time picker dial color roles used for light and dark themes:  - On surface variant - On surface - Surface container highest - On surface - Tertiary container - On tertiary container - Surface container high - Outline - On surface - Primary - On primary - Primary - On surface variant - On surface - Surface container highest - On primary container - Primary container_
_altText: Side-by-side diagram indicating the 17 different color elements of a time picker dial._

### Time picker input color

_footer: Time picker input color roles used for light and dark themes:  - On surface variant - On surface - Surface container highest - On surface - Tertiary container - On tertiary container - Surface container high - Outline - On surface - Primary - On surface variant - On primary container - Primary container_
_altText: Side-by-side diagram indicating the 13 different color elements of a time picker input._

## States

_footer: - Enabled - Hover - Focus - Pressed_
_altText: Diagram showing the 4 interactive states of a time picker, in both light theme and dark theme._

[States specs can be found in the token module above](/m3/pages/time-pickers/specs#2ccd9809-9246-4667-85fa-7747f4ac7349)

## Measurements

### Time picker dial - vertical

_footer: Vertical time picker dial padding and size measurements_
_altText: Diagram of vertical time picker dial measurements._

Element | Attribute | Value |

Container
 |
Width
 |
Dynamic
 |

Height
 |
Dynamic
 |

Headline alignment
 |
Left
 |

Top/bottom padding
 |
24dp
 |

Left/right padding
 |
24dp
 |

Time selector container
 |
Width
 |
96dp
 |

Width (24h vertical)
 |
114dp
 |

Height
 |
80dp
 |

Period selector container
 |
Width (vertical layout)
 |
52dp
 |

Height (vertical layout)
 |
80dp
 |

Width (horizontal layout)
 |
216dp
 |

Height (horizontal layout)
 |
38dp
 |

Clock dial container
 |
Size
 |
256dp
 |

Clock dial selector handle
 |
Size
 |
48dp
 |

Clock dial selector center
 |
Size
 |
8dp
 |

Clock dial selector track
 |
Width
 |
2dp
 |

### Time picker dial - horizontal

_footer: Horizontal time picker dial padding and size measurements_
_altText: Diagram of horizontal time picker dial measurements._

Element | Attribute | Value |

Container
 |
Width
 |
Dynamic
 |

Height
 |
Dynamic
 |

Headline alignment
 |
Left
 |

Top/bottom padding
 |
24dp
 |

Left/right padding
 |
24dp
 |

Time selector container
 |
Width
 |
96dp
 |

Width (24h vertical)
 |
114dp
 |

Height
 |
80dp
 |

Period selector container
 |
Width (vertical layout)
 |
52dp
 |

Height (vertical layout)
 |
80dp
 |

Width (horizontal layout)
 |
216dp
 |

Height (horizontal layout)
 |
38dp
 |

Clock dial container
 |
Size
 |
256dp
 |

Clock dial selector handle
 |
Size
 |
48dp
 |

Clock dial selector center
 |
Size
 |
8dp
 |

Clock dial selector track
 |
Width
 |
2dp
 |

### Time picker input

_footer: Time picker input padding and size measurements_
_altText: Diagram of time picker input measurements._

Element
 | Attribute | Value |

Container
 |
Width
 |
Dynamic
 |

Height
 |
Dynamic
 |

Headline alignment
 |
Left
 |

Top/bottom padding
 |
24dp
 |

Left/right padding
 |
24dp
 |

Time input field container
 |
Width
 |
96dp
 |

Height
 |
72dp
 |

Period selector container
 |
Width
 |
52dp
 |

Height
 |
72dp
 |

## Configurations

### Vertical orientation and horizontal orientation

_footer: - Vertical layout (default on mobile) - Horizontal layout_
_altText: Comparing vertical and horizontal time picker dials._

### 24-hour time picker dial

_footer: - 24h dial in vertical layout (default on mobile) - 24h dial in horizontal layout_
_altText: 2 24-hour time picker dials with vertical and horizontal layouts._

### 12-hour and 24-hour time picker inputs

_footer: - 12h input - 24h input_
_altText: Compare 12-hour and 24-hour time picker inputs._

<!-- section: Guidelines -->

_footer: Dial selector time picker for a 12-hour clock_
_altText: Time picker. It has a dial and keyboard input for hours and minutes, and a setting for AM or PM._

## Usage

Time pickers allow people to enter a specific time value. They’re displayed in dialogs and can be used to select hours, minutes, or periods of time.

They can be used for a wide range of scenarios. Common use cases include:

- Setting an alarm
- Scheduling a meeting

Time pickers are not ideal for nuanced or granular time selection, such as milliseconds for a stopwatch application.

_footer: Hour selection in a mobile calendar picker_
_altText: Time picker with dial input selecting hour 7._

### Time input picker

Time input pickers allow people to specify a time using keyboard numbers. This input option should be accessible from any other mobile time picker interface by tapping the keyboard icon.

_footer: Hour input with keyboard entry_
_altText: Input time picker with keyboard active for the hour._

### 24-hour time selection

The dial view can be changed to reflect time selection across 24 hours. This option is set outside of the time picker component, typically through system settings.

_footer: 24-hour dial view_
_altText: Time picker with dial input selecting hour 20. Hours 0–11 use an outer dial, hours 12–23 use an inner dial._

## Anatomy

_footer: - Label (headline) - Time selector separator - Input field - Input text - Period selector (selected) - Period selector text (selected) - Container - Period selector outline - Period selector text - Dial selector track - Dial label (selected) - Text buttons - Icon button - Dial label (unselected) - Clock dial - Input text (selected) - Input field (selected)_
_altText: 17 elements of a dial time picker._

_footer: - Label (headline) - Time selector separator - Input field - Input text - Period selector (selected) - Period selector text (selected) - Container - Period selector outline - Period selector text (unselected) - Text buttons - Icon button - Input text (selected) - Input field (selected)_
_altText: 13 elements of an input time picker._

### Container

Like dialogs, the container should appear above other screen elements. To focus attention, surfaces behind the container have a temporary scrim overlay to make them less prominent.

_footer: The container includes all time picker elements_
_altText: Time picker container, all elements inside._

### Input selector

The input selector is a unique kind of text field input. It differs from typical text field inputs in that it has:

-
An added highlight to call attention to the selected field

-
A larger shape, size, and font

-
A label below the field

Hours and minutes should have separate inputs. For people using a 12-hour clock, an AM/PM selector appears to the right of minutes. For people using a 24-hour clock, the AM/PM selector shouldn’t appear.

_footer: Input selector for a 12-hour clock_
_altText: Input time picker with the hour field active, and so highlighted._

### Dial selector

Dial selectors always mimic a round watch face. Hours and minutes can be selected by tapping a number or dragging the dial selector track.

When representing a 12-hour dial, all numbers appear in the outer ring. When representing a 24-hour dial, even numbers appear in an inner ring, and odd numbers appear in an outer ring.

_footer: Dial selector for a 12-hour clock_
_altText: Dial time picker with hour 7 selected._

### Text & icon buttons

Icon buttons are used to switch between the input selector, represented by a keyboard, and the dial selector, represented by a clock.

Text buttons are used to exit the dialog (**Cancel**) and save the selector input (**OK**).

_footer: The keyboard icon allows people to switch between the dial selector (pictured) and the input selector_
_altText: Time picker buttons._

### Landscape orientation

The clock dial interface adapts to a device’s orientation. In landscape mode, the stacked input and selection options are positioned side-by-side.

_footer: On mobile, the time picker can adapt to landscape orientation_
_altText: Time picker in landscape orientation on mobile._

## Placement

Time pickers shouldn’t be obscured by other elements.  

Time pickers should change orientation or variant to ensure they aren't cropped by the edge of the screen.

Time pickers are modal windows above a scrim. This puts the time pickers at the forefront of a person's view, calling attention to make a selection of time.

_footer: The time picker should change to fit the size of the screen so the time picker is always fully visible_
_altText: Input time picker in landscape orientation on mobile. It's fully visible despite the limited device height._

## Adaptive design

Time pickers can swap between orientation or variant depending on device orientation and viewport constraints. 

For example, the time picker can change to landscape orientation on larger breakpoints or when viewport height is limited, to avoid scrolling the dial presentation. 

Time pickers can fallback to the input time picker when there isn’t enough vertical real estate to present the landscape orientation without scrolling.

_footer: High-density time picker displayed on mobile_
_altText: Dial time picker in portrait orientation on mobile._

### Density

Don’t apply density to the time picker dial when the viewport is constrained. Instead, use an input picker.

_footer: Don’t apply density to the time picker dial when the viewport is constrained. Instead, use an input picker._
_altText: Dial time picker in portrait orientation, too tall to fully fit on a mobile device in landscape mode._

## Behavior

There are two primary methods for selecting time with the mobile time picker. People can:

- Type in a specific value in the hour and minute fields
- Select the hour or minute field from the text input and adjust the clock dial to simultaneously change the corresponding time field above

_footer: The dial time picker supports both manual and dial input_
_altText: Dial time picker possible interactions. Dial selector adjusts to match manual input._

### Appearing & disappearing

Like other kinds of dialogs, time pickers use an enter and exit transition pattern to appear on the screen.

To exit a time picker, the input can either be confirmed (**OK**) or dismissed (**Cancel**). Interacting outside of the dialog will also dismiss the time picker. Unless one of these actions is taken, a time picker will continue to retain focus.

_footer: OK confirms the entry and closes the dialog_
_altText: Time picker enter and exit transitions._

### Toggle between dial & input

Tapping the keyboard icon on a mobile time picker switches the view to the input picker.

_footer: The keyboard icon in the lower left toggles between the input picker and the dial picker_
_altText: Time picker transitioning between dial and input selectors._

### Scrolling

Time pickers should avoid scrolling, and swap component orientation or variant based on device orientation or viewport size. 

Time pickers don’t scroll with elements outside of the modal window, such as the background.

_footer: Time pickers shouldn’t scroll_
_altText: Input time picker in landscape orientation to fit a mobile device in landscape mode._

<!-- section: Accessibility -->

## Use cases

People should be able to use assistive technology to: 

- Select or enter hours/minutes, and in some cases, seconds/milliseconds
- Choose from multiple time formats, including 24-hour clock view and AM/PM
- Enter time selection manually using input fields

## Interaction & style

Time pickers should allow manual time entry through text input, rather than exclusively through the dial selector. This makes it easier for those using keyboard inputs rather than touchscreens. 

If a screen is not large enough to display the dial selector, consider displaying the input selector alone. Currently for Android Views, the dial selector is always visible.

The input selector should be accessible from the dial selector via the keyboard icon. This interaction allows multiple input methods and makes the time picker accessible for assistive technology users.

_footer: For time selection that doesn’t require a dial view, make a time input picker the default option_
_altText: Time picker with active manual text input for hours._

### Targets

Targets for dial selectors should be 48x48dp.

_footer: Dial selector targets should be 48x48dp_
_altText: Time picker dial selector specs, selecting hour 7._

## Keyboard navigation

Keys | Actions |
**Tab** | Focus lands on (non-disabled) time slot |
**Space** or **Enter**
 | Activates the (non-disabled) time slot |

## Labeling elements

If the input text is correctly linked, assistive tech like a screenreader will read the component’s role first, then the UI text.

_footer: The hour and minute fields have the text input role_
_altText: Accessibility tags on the time picker's hour input field._

The dial selector will read a selection of total hours, such as **Hour 7 of 12**.

_footer: A screen reader reads the text label of a dial selector_
_altText: Accessibility tag on the time picker's dial selector._

### Dial selector
Element
 | Accessibility label | Role (Wiz and Jetpack Compose)
 | Role (Android Views)
 |
Hour input (input picker)
 | Hour | Text input | - |
Minutes input
 | Minute | Text input | - |
AM/PM selection 
 | AM or PM | Radio button (in list) | Checkbox (in list) |
Keyboard button
 | Toggle input picker | Button | Button |
Cancel button
 | Cancel | Button | Button |
OK button
 | OK | Button | Button |
Clock dial time selection (dial selector)
 | {Value} Hours or minutes of {Total} | Button | - |

### Input selector
Element
 | Accessibility label | Role (Wiz and Jetpack Compose)
 | Role (Android Views)
 |
Hour input (input picker)
 | Hour | Text input | - |
Minutes input
 | Minute | Text input | - |
Clock button
 | Toggle dial picker | Button | Button |
Cancel button
 | Cancel | Button | Button |
OK button
 | OK | Button | Button |
