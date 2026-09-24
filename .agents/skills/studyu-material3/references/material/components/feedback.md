# Material 3 · Feedback

<!-- Source: m3.material.io · components_snackbar · updated 2026-07-28T08:03:08.607Z · CC-BY 4.0 (Google) -->

## Snackbar



<!-- section: Overview -->

- Snackbars shouldn’t interrupt the user’s experience
- Usually appear at the bottom of the UI
- Can disappear on their own or remain on screen until the user takes action

_altText: Diagram of snackbar placement_

## Availability & resources

## Differences from M2

- Color: New color mappings and compatibility with dynamic color
- Behavior: Clarified that snackbars can either appear temporarily (dismissive) or persist until the user takes an action (non-dismissive)

_footer: Snackbars have new color mappings_
_altText: Example of snackbar on screen bottom_

<!-- section: Specs -->

_footer: - Container  - Icon (optional close affordance)  - Action (optional)  - Supporting text_
_altText: Diagram of snackbar indicating the four parts of its anatomy_

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](/m3/pages/design-tokens/overview)

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Snackbar color roles used for light and dark schemes:  - Inverse surface - Inverse on surface - Inverse primary - Inverse on surface_
_altText: Diagram of snackbar indicating color and inverse text and labels_

## Measurements

_footer: Snackbar padding and size measurements_
_altText: Diagram of snackbar with action_

## Configurations

_footer: - Single line - Single line with action - Two lines - Two lines with action - Two lines with longer action_
_altText: 5 snackbar configurations._

<!-- section: Guidelines -->

_altText: Snackbar at the bottom of a mobile device._

## Usage

Snackbars inform users of a process that an app has performed or will perform. They appear temporarily, towards the bottom of the screen.

They shouldn't interrupt the user experience. People can browse the page content without being required to interact with the snackbar.

**Frequency**
Only one snackbar may be displayed at a time.

**Actions**
A snackbar can contain a single action. "Dismiss" or "cancel" actions are optional.

_altText: Snackbar showing 'Email archived' text with an 'Undo' text button._

### Similar components

Dialogs are also designed to show important messages.

Choose the right component based on the importance of the message. This component messaging strategy can help avoid overusing snackbars.

_footer: Dialogs require immediate action_
_altText: Dialog on a phone requiring the user to sign in to continue. Dismissing prevents them from progressing._

**When to use snackbars**
Snackbars communicate messages that are minimally interruptive and don’t require user action.

Component | Priority | User action |
Snackbar | Low priority | Optional: Snackbars disappear automatically |
Dialog | High priority | Required: Dialogs block app usage until the user takes a dialog action or exits the dialog (if available) |

### Accessibility requirements for web

On web, auto-dismissing snackbars are inaccessible for people with low vision or who require additional time to perceive information. This can be solved in 2 ways:

#### 1. Add inline feedback

Information in auto-dismissing snackbars must also be communicated using another accessible method inline or near the action that triggered the snackbar. 

For example, update the label on a "Save" button to “Saved”, and trigger an auto-dismissing snackbar that communicates the same message. 

#### 2. Make the snackbar actionable

Alternatively, add actions to the snackbar so it doesn't dismiss until acted on.

_footer: Also communicate snackbar information near the action that triggered the snackbar_
_altText: A button labelled "Save" changes to "Saved" after a moment. A snackbar confirms all changes are saved._

## Anatomy

_footer: - Container - Supporting text - Action (optional) - Close button (optional)_
_altText: 4 elements of a snackbar._

### Text label

Snackbars contain a text label that directly relates to the process being performed. In compact breakpoints, the text label can contain up to two lines of text.

_footer: Text labels are short, clear updates on processes that have been performed_
_altText: Snackbar on a mobile device reading: "Saved in Vacation album"._

_footer: Keep the snackbar text label to one line long when possible_
_altText: Snackbar on mobile with one line of content._

_footer: On mobile, the text label can be up to two lines long_
_altText: Snackbar on mobile with two lines of content._

_footer: Avoid adding icons to snackbars. If your message needs an icon, consider using a different component such as a dialog._
_altText: Snackbar on mobile with an icon and one line of content._

_footer: Avoid using stylized text or inline links in snackbars; they can add unwanted complexity. If your message needs a link, add a button instead, or use a different component._
_altText: Snackbar on mobile with bolded and hyperlinked words._

### Container

Snackbars are displayed in rectangular containers with a grey background. Containers should be completely opaque, so that text labels remain legible.

_footer: Snackbar containers use a solid background color with a shadow to stand out against content_
_altText: Snackbar showing a light text label on a black color container._

_footer: The text label shouldn’t share the same color as the text button_
_altText: A snackbar with button text the same color as supporting text._

_footer: Don’t use a filled or elevated button in a snackbar, as it draws too much attention_
_altText: A snackbar with the action in elevated style._

_footer: In wide layouts, extend the container width to accommodate longer text labels_
_altText: An extended snackbar on tablet with a long text label._

_footer: An app can apply slight transparency to the container background, as long as text remains clearly legible_
_altText: Snackbar with a slightly transparent container and a clearly visible text label._

_footer: Avoid significantly altering the shape of a snackbar container_

### Action

Snackbars can display a single text button that lets users take action on a process performed by the app. Snackbars shouldn’t be the only way to access a core use case, to make an app usable.

_footer: To distinguish the action from the text label, text buttons should display colored text_
_altText: A snackbar container with rounded corners._

_footer: If an action is long, it can be displayed on a third line_
_altText: Snackbar with a long text button displayed on a third line._

_footer: To allow users to amend choices, display an "Undo" action_
_altText: Snackbar with a single text button labeled undo._

_footer: A dismiss action is unnecessary, as snackbar disappears on their own by default_
_altText: Snackbar with a single text button labeled dismiss._

## Placement

### At the bottom of a UI

Snackbars should be placed at the bottom of a UI, in front of the main content. In some cases, snackbars can be nudged upwards to avoid overlapping with other UI elements near the bottom, such as FABs or docked toolbars.

Avoid placing a snackbar in front of frequently used touch targets or navigation.

_footer: Place a snackbar in front of the main content_
_altText: Snackbar appearing in front of photo content._

_footer: Avoid placing snackbars in front of navigation components_
_altText: Snackbar placed in front of the navigation components._

To ensure accessibility for keyboard users on the web, avoid positioning the snackbar in a way that completely obscures actionable elements. Blocking elements makes it difficult to know what is being focused and selected.

_footer: Adjust the size of the snackbar to avoid blocking elements in focus_
_altText: Thin snackbar in front of a focused element that is still visible._

_footer: Don’t let the snackbar fully cover elements in focus_
_altText: Larger snackbar that is obscuring a focused element._

Snackbars can span the entire width of the screen only when a UI does not use persistent navigation components like app bars or navigation bars.

Snackbars that span the entire width of a UI can push up FABs when they appear.

_footer: Snackbars can span the entire width of a UI. However, they should not appear in front of navigation or other important UI elements like floating action buttons._
_altText: Snackbar spanning the width of a mobile device is placed in front of the navigation components and FAB._

**Snackbars and floating action buttons (FABs)**

Snackbars should appear above FABs.

_footer: Snackbar above a FAB_
_altText: Snackbar placed above a FAB on a mobile device._

_footer: Don’t place a snackbar in front of a FAB_
_altText: Snackbar placed in front of a FAB on a mobile device._

_footer: Don’t place a snackbar behind a FAB_
_altText: Snackbar placed behind a FAB on a mobile device._

## Responsive layout

### Compact breakpoint

In compact breakpoints, snackbars should expand vertically from 48dp to 64dp to accommodate one or two lines of text, while maintaining a  fixed distance from the leading, trailing, and bottom edges of the screen.

_altText: Snackbar with its label text extending to the second line and maintaining fixed distance from the edges of a mobile device._

### Medium & expanded breakpoints

On medium and expanded breakpoints, like tablet and desktop, snackbars should scale horizontally to accommodate longer text strings, keeping in mind that the ideal line length for text is typically between 40-60 characters.

Snackbars use a flexible distance from the trailing edge of the screen. Whenever possible, snackbars on medium and large displays should aim for a single line of text with an  optional button.

_altText: A horizontally expanded snackbar placed at the bottom of screen on a medium-size device._

In wider layouts, snackbars can be left-aligned or center-aligned if they are consistently placed on the same spot at the bottom of the screen.

_footer: Left-aligned snackbar_
_altText: A left-aligned snackbar placed at the bottom of screen on a medium-size device._

_footer: Center-aligned snackbar_
_altText: A center-aligned snackbar placed at the bottom of screen on a medium-size device._

_footer: Don’t place snackbars flush to one edge of the layout_
_altText: Snackbar displayed at the left edge of the screen, near the bottom, on a medium-sized device._

_footer: Don’t place consecutive snackbars side by side or next to one another_
_altText: 2 snackbars placed side-by-side at the bottom of the screen on a medium-size device._

## Behavior

### Appearing and disappearing

Snackbars appear without warning, but they don’t block users from interacting with page content.

Snackbars without actions can auto-dismiss after 4–10 seconds, depending on platform. Avoid using auto-dismissing snackbars on web unless there's also inline feedback.

_altText: Snackbar without an action button appearing and disappearing within 4 seconds from the screen of a mobile device._

Snackbars with actions should remain on the screen until the user takes an action on the snackbar, or dismisses it.

_altText: Snackbars with actions should remain on the screen until the user takes an action on the snackbar, or dismisses it._

### Consecutive snackbars

Consecutive snackbars must appear one at a time. 

Snackbars without actions appear and disappear automatically, while those with actions remain on screen until dismissed. However, a snackbar with updated information can immediately replace an outdated snackbar.

_altText: Two snackbars appear sequentially on a mobile device. The first includes an action button._

_footer: Don’t stack snackbars on top of one another_
_altText: 2 snackbars appear sequentially on a mobile device and are stacked on top of one another. The first includes an action button._

_footer: Don’t animate other components along with snackbar animations, such as the floating action button_
_altText: FAB's position is displaced when a snackbar enters the screen of a mobile device._

<!-- section: Accessibility -->

### Use cases

Users should be able to:

- Be alerted, but not disrupted, when a snackbar appears
- Move focus to an actionable snackbar
- Take action on a snackbar using assistive technology

### Interaction & style

Snackbars with actions shouldn't auto-dismiss. This way, users can read and interact with it at their own pace.

Snackbars without actions can auto-dismiss after a sufficient amount of time, however this can still present difficulties on web without additional feedback. 

Each platform has its own requirements for auto-dismiss durations, however common acceptable durations are 4–10 seconds.

_footer: Auto-dismissing snackbars should remain on screen long enough to read the information_
_altText: A snackbar saying "Email marked as read" with no button._

Snackbars use a color intended to stand out against UI elements. Use the default color mapping to avoid color conflict issues.

_footer: Snackbar should visually stand out_
_altText: Snackbar with a dark container on a UI page in light theme._

### Accessibility requirements on web

On web, auto-dismissing snackbars can be difficult to navigate for people with low vision or who require additional time to perceive information. This information can be made clearer for all users in two ways:

#### 1. Add inline feedback

Information in auto-dismissing snackbars must also be communicated inline or near the action that triggered the snackbar.

For example, update the label on a "Save" button to “Saved”, and trigger an auto-dismissing snackbar that communicates the same message.

#### 2. Make the snackbar actionable

Alternatively, add actions to the snackbar so it doesn't dismiss until acted on. Actionable snackbars shouldn't auto-dismiss.

_footer: Communicate snackbar information near the action that triggered the snackbar_
_altText: A "save" button changes to say "saved", alongside a snackbar that confirms changes were saved._

Note: Material Web doesn't yet include the snackbar component. This guidance still applies to custom-made snackbars.

### Focus

Snackbars have the following focus requirements:

- When a snackbar appears, announce the message but don't move focus.
- Don't automatically move focus.
- Don't trap focus in the snackbar. Users should be able to freely navigate in and out.
- On web, a shortcut should exist for users to move focus to snackbars with actions (like Alt+G). Ensure that this shortcut is clearly documented, like in a help article.

_footer: Focus returns from the snackbar (1) to the previously focused element (2)_
_altText: Taking a menu item action moves focus to a snackbar. Moving focus out of the snackbar returns it to the same menu item._

Focus exits the snackbar differently per platform:

- Ideally, focus should either return to the element that triggered the snackbar, or go to the next most logical element on the page.
- On Android Compose, focus may move to the nearest visible element, or to the first actionable item on the page.

_footer: If the previously focused element is no longer on the page, focus should move from the snackbar (1) to the next most logical element (2)_
_altText: Confirming in a dialog moves focus to a snackbar. Moving focus out of the snackbar returns it to a page element._

### Keyboard navigation
Keys | Actions |
Tab | Moves focus between interactive elements |
Esc | Dismisses the snackbar when in focus |

### Labeling elements

Snackbars should be announced once they appear on the screen, but shouldn’t grab focus or prevent people from completing their current task. 

- On Android and web, use a live region with a polite (queued) announcement instead of an assertive announcement.
- On iOS 17+, snackbars use polite announcements by default.

If a snackbar appears when the app is launched, it should be announced after the page’s title, but not receive focus.

_footer: Snackbars are announced when they appear, but don't trap focus_
_altText: Snackbar accessibility label examples._

---

<!-- Source: m3.material.io · components_tooltips · updated 2026-07-17T07:03:02.412Z · CC-BY 4.0 (Google) -->

## Tooltips



<!-- section: Overview -->

-
Use tooltips to add additional context to a button or other UI element

-
Two variants: plain and rich

-
Use plain tooltips to describe elements or actions of icon buttons

-
Use rich tooltips to provide more details, like describing the value of a feature

-
Rich tooltips can include an optional title, link, and buttons

_footer: - Plain tooltip - Rich tooltip_
_altText: 2 variants of tooltips._

## Availability & resources

## Differences from M2

-
**Color**: New color mappings and compatibility with dynamic color

-
**Shape**: Rich tooltips have more rounded corners

_footer: M2: Rich tooltips have slightly rounded corners_
_altText: GM2 rich tooltip._

_footer: M3: Rich tooltips have more rounded corners and support dynamic color_
_altText: GM3 rich tooltip._

<!-- section: Specs -->

## Tokens & specs

Select a component variant below to see its attributes, tokens, and values.

## Plain tooltip

_footer: - Supporting text - Container_
_altText: 2 elements of a plain tooltip._

### Plain tooltip colors

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Plain tooltip color roles used for light and dark themes:  - Inverse on surface - Inverse surface_
_altText: 2 color roles of a plain tooltip._

### Plain tooltip measurements

_footer: Plain tooltip padding and size measurements_
_altText: Measurements of a plain tooltip._

Attribute
 |
Value
 |

Container height
 |
24dp
 |

Padding
 |
8dp
 |

## Rich tooltip

_footer: - Subhead - Container - Supporting text - Text button_
_altText: 4 elements of a rich tooltip._

### Rich tooltip colors

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Rich tooltip color roles used for light and dark themes:  - On surface variant - Surface container - On surface variant - Primary_
_altText: 4 color roles of a rich tooltip._

### Rich tooltip measurements

_footer: Rich tooltip padding and size measurements_
_altText: Measurements of a rich tooltip._

Attribute | Value |
Top padding | 12dp |
Bottom padding | 8dp |
Left and right padding | 16dp |

### Rich tooltip configurations

Rich tooltips can have a headline, body, and up to two buttons. The headline and number of buttons can be configured.

_footer: - Subhead, supporting text, and two buttons - Subhead, supporting text, and one button - Subhead and supporting text - Supporting text and one button - Supporting text and two buttons_
_altText: 5 common configurations of a rich tooltip._

<!-- section: Guidelines -->

_footer: Plain and rich tooltips serve different purposes_
_altText: A plain tooltip labeling a button, and a rich tooltip announcing new settings available._

## Usage

A tooltip provides additional context for a UI element. 

**Plain tooltips**
Plain tooltips briefly describe a UI element. They're best used for labelling UI elements with no text, like icon-only buttons and fields.

**Rich tooltips**
Rich tooltips provide additional context about a UI element. They can optionally contain a subhead, buttons, and hyperlinks.

Rich tooltips are best used for longer text like definitions or explanations.

_footer: - Plain tooltip - Rich tooltip_
_altText: 2 variants of tooltips._

_footer: Use plain tooltips to label icon-only buttons_
_altText: Plain tooltip labeling an icon-only button in Google Meet as "Present now"._

_footer: Plain tooltips aren't needed when the UI element already has label text_
_altText: Button with an icon and label text saying "Edit". It has a plain tooltip on hover that also says "Edit"._

_footer: Use rich tooltips to provide extra information and actions about a UI element or new feature_
_altText: Rich tooltip describing a new button for adding people. It has a subhead, description, and a button to learn more._

_footer: Don't hide critical information within tooltips as it’s easy to miss. Use an interruptive dialog instead._
_altText: Rich tooltip explaining that an action is destructive and permanently deletes files._

## Anatomy

### Plain tooltip

_footer: - Container - Supporting text_
_altText: 2 elements of a plain tooltip._

### Supporting text

_footer: Briefly describe a UI element_
_altText: Plain tooltip for an icon-only button shaped like a gear. The tooltip text is "Settings"._

_footer: Avoid wrapping text to multiple lines or including many pieces of information_
_altText: Plain tooltip for the account switcher. The supporting text includes the user's name and email address on new lines._

### Rich tooltip

_footer: - Subhead (optional) - Container - Supporting text - Text button (optional)_
_altText: 4 elements of a rich tooltip._

### Subhead (optional)

Keep subheads brief, ideally to one line. They should summarize or describe the message of the rich tooltip.

Subheads are important to include when the rich tooltip appears automatically, like when the page loads.

_footer: Summarize the message in a few words_
_altText: Rich tooltip with a brief subhead, supporting text, and a text button._

_footer: Avoid wrapping to more than one line_
_altText: Rich tooltip with a subhead wrapping to multiple lines._

### Text buttons (optional)

Rich tooltips can have up to two text buttons. These should be brief and relevant to the message in the supporting text.

Keep buttons short so they can be side by side. Avoid stacking them when possible.

_footer: Avoid stacking buttons_
_altText: Rich tooltip with 2 buttons stacked on each other._

## Placement

### Plain tooltips

By default, plain tooltips are positioned directly above the parent element. 

- If there's a visual boundary, like a button, the distance is 4dp
- If there's no visual boundary, like with text baselines, the distance is 8dp

If the element is in an app bar, the plain tooltip appears below the element at the same distance.

_footer: Plain tooltip with a 4dp distance between the target and tooltip_
_altText: Plain tooltip appearing 4dp below a button with a clear visual boundary._

### Rich tooltips

By default, rich tooltips are positioned to the bottom right of the parent element. They adjust position to avoid going off screen.  Tooltips shouldn't cover the parent element. 

**Dynamic positioning**
The position of the tooltip adjusts in increments of 8dp to avoid going off-screen.

**Desktop placement**
On desktop, tooltips may appear centered below the parent element and remain visible while moving within the target region.

_footer: Four different rich tooltip locations based on dynamic positioning_
_altText: A rich tooltip in 4 different corners. It   changes position to remain fully on screen._

## Behavior

To show a tooltip, hover on the parent element on desktop, or tap and hold the element on mobile. Persistent rich tooltips only appear when clicked or tapped.

### Transient by default

Both plain and rich tooltips disappear 1.5 seconds after navigating away from the target region.

Triggering a new tooltip immediately closes any other open tooltip.

_footer: Tooltips disappear after a 1.5 second delay when no other element is hovered_
_altText: Hovering and moving from a button with a plain tooltip._

_footer: Only display one tooltip at a time_
_altText: 2 buttons both showing plain tooltips at once._

### Persistent rich tooltips

Persistent rich tooltips appear when either:

- The parent element is clicked
- The page loads and a new feature is being explained

Persistent rich tooltips remain active even when leaving the target region. They only disappear once a person interacts with another UI element. Hovering doesn't trigger the tooltip.

When appearing on page load, the tooltip can introduce and explain new features on various parent elements.

Avoid using persistent rich tooltips on icon buttons.

_footer: Don’t use a persistent rich tooltip on icon buttons_
_altText: Persistent rich tooltip about a new sharing feature in the Photos app. The button says  "Learn more.”_

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Receive a tooltip message
- Activate a tooltip with a keyboard or switch input

## Interaction & style

Plain and rich tooltips without required actions should remain on screen long enough for people to receive the information without disrupting their existing flow or task.

_footer: Plain tooltips should remain on the screen temporarily after the cursor moves away_
_altText: A cursor hovers over an icon that identifies it as a star, which remains after moving away._

Tooltips can appear when an actionable element, like a button or navigation rail, is hovered or focused. However, this tooltip shouldn’t hide crucial information.

Rich tooltips can also appear by selecting an element instead of hovering or focusing on it.

_footer: Tooltips can appear on hover or focus to explain actions_
_altText: A cursor hovers over a favorite button producing text about finding this item later in favorites._

_footer: Rich tooltips can appear when an element is selected_
_altText: An information button in a selected state produces text about finding this item later in favorites._

## Focus order

Tooltip containers should not block important information or prevent a person from completing an action. 

Focus order within the rich tooltip moves top to bottom between interactive elements. 

Avoid trapping screen reader and keyboard focus on rich tooltips.

People should be able to move linearly through the rest of the page.

_footer: - Parent element - Inline link - Text button_
_altText: Different elements of a rich tooltip are given a focus order, moving from parent element to inline link to text button._

## Keyboard navigation

**Keys**
 |
**Actions**
 |

**Tab**
 |
Focus lands on button, if available
 |

**Space** or **Enter**
 |
Activates the focused element
 |

## Labeling elements

Tooltips should have the **Tooltip** role, or similar. 

Label all elements in the tooltip according to their own accessibility guidance.

_footer: The tooltip container should have the **Tooltip** role_
_altText: A rich and plain tooltip with all elements matched to accessibility labels._

---

<!-- Source: m3.material.io · components_badges · updated 2026-07-17T06:58:42.753Z · CC-BY 4.0 (Google) -->

## Badges



<!-- section: Overview -->

-
Can contain labels or numbers

-
Two variants: small and large

-
Anchor badges inside the icon bounding box, at the upper trailing edge of the icon

-
Limit content to four characters, including a **+**

-
Keep the default color mapping

_footer: - Small badge on a navigation item - Large badge on a navigation item - Large badge with max characters on a navigation item_
_altText: 3 icons with badges. 1 is a small dot. 2 is a larger circle with a 1 digit number. 3 is an oval with a 4 digit number._

## Availability & resources

## Differences from M2

-
Color: New color mappings and compatibility with dynamic color

_footer: Badges have new color mappings_
_altText: Navigation bar showing 4 icons with different badge variants in a bright red color._

<!-- section: Specs -->

_footer: Navigation bar  - Small badge - Large badge container - Large badge label - Large badge maximum character count container - Large badge maximum character count label_
_altText: 5 aspects of badge anatomy on a navigation bar._

_footer: Navigation rail  - Small badge - Large badge container - Large badge label - Large badge maximum character count container - Large badge maximum character count label_
_altText: 5 aspects of badge anatomy on a navigation rail._

## Tokens & specs

Browse the component elements, attributes, tokens, and their values.

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

_footer: Badge color roles used for light and dark schemes in navigation bar:  - Error - Error - On error - On error - Error_
_altText: 5 applications of badge color on light and dark theme navigation bars._

_footer: Badge color roles used for light and dark schemes in navigation rail:  - Error - On error - Error - On error - Error_
_altText: 5 applications of badge color on light and dark theme navigation rails._

## Measurements

_footer: Badge padding and size measurements_
_altText: Annotation of badge sizes, padding, and measurements from the corner of the icon to the badge opposite corner._

Attribute
 |
Value
 |

Small badge shape
 |
3dp corner radius
 |

Small badge size (HxW)
 |
6dp
 |

Large badge shape
 |
8dp corner radius
 |

Large badge one digit size (HxW)
 |
16dp
 |

Large badge max character count size (HxW)
 |
16x34dp
 |

Small badge: distance from top trailing icon corner to bottom leading badge corner (HxW)
 |
6x6dp
 |

Large badge: distance from top trailing icon corner to bottom leading badge corner (HxW)
 |
14x12dp
 |

Large badge padding between badge and text container
 |
4dp
 |

## Configuration

Different badges are shown on navigation destinations in various states.

_altText: Diagram of 3 badge variations shown on navigation destinations in various states._

- Inactive with label - small badge
- Inactive with label - large badge
- Inactive with label - large badge max character count
- Inactive - small badge
- Inactive - large badge
- Inactive - large badge max character count
- Active with label - small badge
- Active with label - large badge
- Active with label - large badge max character count
- Active nav bar no label - small badge
- Active nav bar no label - large badge
- Active nav bar no label - large badge max character count
- Active nav rail no label - small badge
- Active nav rail no label - large badge
- Active nav rail no label - large badge max character count

<!-- section: Guidelines -->

_footer: Large badges and a small badge in a navigation bar_
_altText: Diagram of 4 badges in different configurations on a navigation bar's destination icons._

## Usage

Badges are used to indicate a notification, item count, or other information relating to a navigation destination. They are placed on the ending edge of icons, typically within other components.

There are two variants:

-
Small badge

-
Large badge

_footer: Navigation bar with four badges_
_altText: Diagram of 4 badges in different configurations on a navigation bar's destination icons._

A **small badge** is a simple circle, used to indicate an unread notification.  

A **large badge** contains label text communicating item count information.

_footer: Small badge_
_altText: A small badge is a circle with no characters._

_footer: Large badge_
_altText: A large badge holds 4 characters and expands its container's width but not height._

### With other components

Badges are most commonly used within other components, such as navigation bar, navigation rail, app bars, and tabs.

_footer: In navigation bars, hide the badge once the destination has been selected_
_altText: Navigation bar with 3 icon buttons. 2 icons buttons have badges and 1 doesn't._

## Anatomy

_footer: - Small badge - Large badge container - Large badge label_
_altText: Small and large badges on 2 icon buttons._

## Container

There are two container options for the badge: 

-
Small badge with no text

-
Large badge with text

_footer: A small badge uses only shape to indicate a status change or new notification_
_altText: A small badge on a navigation item._

_footer: A large badge displays a number within a container to indicate a quantifiable status change related to a destination_
_altText: Number 10 displayed within large badge on a navigation item._

Badge containers are anchored inside the icon bounding box. As the number count increases for large badges, their width expands, but keeps the same placement.

Badges use a color intended to stand out against labels, icons, and navigation elements. Use the default color mapping to avoid color conflict issues.

_footer: Change the position of the badge for right-to-left languages_
_altText: Small and large badges on the left side of 2 navigation items in a right-to-left language._

_footer: Badges have fixed positions. Don’t change the position of the badge arbitrarily or place the badge over the icon._
_altText: Small and large badges at random positions on 3 icon buttons on a navigation rail._

_footer: Use the default badge color_
_altText: Small and large badges in default red color on 3 navigation items._

_footer: Avoid using custom color roles for the badge container and label text. If custom roles are necessary, make sure they have contrast of at least 3:1._
_altText: Small and large badges in custom colors on 3 navigation items._

### Label text

Label large badges with counts or a status. The maximum number of characters within large badge label text is four, including a + to indicate more.

_footer: Large badges with one to four characters_
_altText: 4 icons with increasing number badges. The badges represent quantities, using a "+" symbol for quantities over 999._

Use the recommended maximum character count to ensure labels don’t extend beyond the badge container.

_footer: Truncate badge labels as needed_
_altText: 4-digit numbers condensed to a 3-digit badge with "+" to fit the badge container's width._

_footer: Don’t let the badge get cut off or collide with another element_
_altText: 4-digit and 5-digit number badges on navigation items exceed the badge container's width and get cut off at the edge._

## Placement

_footer: Use a large badge to show count information when visual collisions aren’t an issue, such as in a navigation rail_
_altText: Large badge to the right of a navigation rail item._

_footer: Use a small badge when spaces are tightly constrained, such as app bars. Small badges won’t run into the edge of the screen._
_altText: Small badge on an icon button in an app bar._

_footer: When an icon with a badge is followed by text or another element, place a large badge at the trailing edge_
_altText: Large badge placed at the end of a tab._

_footer: Avoid using a large badge when it might overlap with a trailing element. Either place it at the trailing edge or use a small badge instead._
_altText: Large badge overlapping the icon and text in a tab._

<!-- section: Accessibility -->

## Use cases

People should be able to use assistive technology to:

- Understand the dynamic information conveyed in badges, such as counts or labels
- Address badge announcements by selecting corresponding navigation destinations

## Interaction & style

Badges are most commonly used within other components, such as navigation bar, navigation rail, app bars, and tabs.
When a badge is used to indicate an unread notification, the badge gets hidden once it's selected.

_altText: An animation of a badge disappearing once it's tapped._

## Visual indicators

Badges use a color intended to stand out against labels, icons, and navigation elements. Use the default color mapping to avoid color conflict issues.

_footer: Badges must use default color with at least 3:1 contrast_
_altText: Diagram of large and small badges showing that they need to pass 3 to 1 contrast._

_footer: Avoid using custom color roles for the badge container and label text. If custom roles are necessary, make sure they have contrast of at least 3:1._
_altText: Diagram of large and small badges not passing 3 to 1 contrast._

## Labeling elements

The accessibility label for a badge item will be read after its navigation destination. Any numerical badges will have their number read, while non-counting badges will simply announce **New notification**.

_footer: Numerical badges will have their number read_
_altText: Navigation bar highlighting numerical badge._

_footer: Non-counting badges will simply announce **New notification**_
_altText: Navigation bar highlighting non-counting badge._

---

<!-- Source: m3.material.io · components_menus · updated 2026-07-28T07:32:19.493Z · CC-BY 4.0 (Google) -->

## Menus



<!-- section: Overview -->

- Use a **menu** to show a temporary set of actions. To show actions on screen at all times, use a **toolbar** instead
- Menus can open from many components, including icon buttons, split buttons, and text fields
- **Context menus** provide actions for a specific element, like an image or highlighted text, and usually open with a secondary click

_footer: Vertical menus can include vibrant colors, gaps, dividers, and submenus to organize a list of choices_
_altText: 1 vertical menu with vibrant colors opens from a split button, and 1 vertical menu with a submenu._

## Availability & resources

## M3 Expressive update

**November 2025**

**Vertical menus** were introduced with new shapes, color styles, selection states, and refined submenu motion. Gaps can be used for a more flexible layout on Android. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

Variants:

- Added **vertical menus**, recommended for new designs
- Baseline **menu** is still available

Color styles: 

- Standard
- Vibrant

_footer: Vibrant colors help selected menu items stand out_
_altText: A vertical menu using shape and vibrant color to show a selected state._

## Differences from M2

- **Color**: New color mappings and compatibility with dynamic color
- **Variants**: Dropdown menu and exposed dropdown menu are now both referred to as menu, since they differ only in the element which opens the menu surface

_footer: M2: Former menu colors don’t contrast with the background_
_altText: Menu with gray color._

_footer: M3: Menus feature new color mappings and dynamic color_
_altText: Menu with purple background and outline._

<!-- section: Specs -->

## Variants

### Vertical menus

Use vertical menus for a more expressive look and feel, including rounded corners, standard and vibrant color styles, more selection states, and submenu motion.

_footer: - Vertical menu with gap - Vertical menu with divider_
_altText: 2 vertical menus use shape and color to indicate selected state._

### Baseline variant

In M3 Expressive, baseline menu is still available to use, but doesn’t have the latest shapes, color styles, selection states, and motion. [See baseline menu specs](/m3/pages/menus/specs#a80df2f9-8610-4ce0-b3a3-b9ee749d5c98)

_footer: A baseline **menu** has square corners, as compared to a **vertical menu’s** round corners and expressive styling_
_altText: A baseline menu variant with square corners and standard colors._

**Variant**
 |
**M3**
 |
**M3 Expressive**
 |

Vertical menus
 |
--
 |
Available
 |

Menu (baseline)
 |
Available
 |
Available
 |

## Configurations

### Vertical menus layout

_footer: - Standard - Grouped_
_altText: 2 menus: 1 standard, and 1 with a gap, creating groups._

**Category** | **Configuration** | **M3** | **M3 Expressiv****e** |
Color | Standard | Available | Available |
Vibrant | -- | Available |
Layout | Standard | Available | Available |
Grouped | -- | Available |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](/m3/pages/design-tokens/overview)

## Anatomy

### Vertical menus

_footer: - Menu item - Leading icon (optional) - Menu item text - Trailing icon (optional) - Badge (optional) - Trailing text (optional) - Container - Supporting text (optional) - Label text (optional) - Gap (optional) - Divider (optional)_
_altText: A diagram of a vertical menu._

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](/m3/pages/design-tokens/overview)

Menus have two color mappings:

- Standard: Surface-based
- Vibrant: Tertiary-based

These mappings provide options for lower or higher visual emphasis. Vibrant menus are more prominent so should be used sparingly.

_footer: - Standard color scheme - Vibrant color scheme_
_altText: 2 vertical menus: 1 with lower visual emphasis, and 1 vibrant menu with bold shades._

### Standard colors

_footer: Vertical menus color roles used for light and dark themes:  - On surface variant - On surface - On surface (state layer) - Surface container low - On surface variant - On surface variant - Tertiary container (selected) - On tertiary container (selected) - On surface variant - On surface variant - On tertiary container (selected)_
_altText: 2 vertical menus with standard color roles mapped to 11 elements._

### Vibrant colors

_footer: Vertical menus color roles used for light and dark themes:  - On tertiary container - On tertiary container - On tertiary container (state layer) - Tertiary container - On tertiary container - On tertiary container - Tertiary (selected) - On tertiary (selected) - On tertiary container - On tertiary container - On tertiary (selected)_
_altText: 2 vertical menus with vibrant color roles mapped to 11 elements._

## States

States are visual representations used to communicate the status of a component or an interactive element. [More on interaction states](/m3/pages/interaction-states/overview)

Shape morphing in vertical menus creates an expressive active state. As focus moves between submenus, the corner shape changes to highlight the active menu. [More on menu focus](/m3/pages/menus/guidelines#7cc1d01b-a454-48c7-8306-e60347ffd17f)

_footer: - Enabled - Disabled - Hovered - Focused - Pressed - Active (main menu reveals submenu)_
_altText: 6 vertical menu states in light and dark themes._

## Measurements

_footer: Vertical menu padding and size measurements_
_altText: Vertical menu marked with spacing and padding measurements._

## Menu (baseline)

The baseline menu variant is available and continues to work in existing products. However, M3 expressive vertical menus are recommended for new designs.

### Baseline tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](/m3/pages/design-tokens/overview)

### Anatomy

_footer: - List item - List item leading icon - List item trailing icon - Container - List item trailing text - Divider_
_altText: Diagram of 6 elements of a baseline menu._

### Color

_footer: Baseline menu color roles used for light and dark themes:  - On surface variant - On surface - On surface - opacity: 0.08 - Surface container - On surface variant - On surface variant - On surface variant - Surface container highest - Outline variant_
_altText: 9 color roles of a baseline menu in light and dark themes._

### States

#### Default menu items

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: Diagram numbering the 5 default states of a baseline menu._

#### Selected menu items

_footer: - Enabled - Disabled - Hovered - Focused - Pressed_
_altText: 5 states of a selected baseline menu item._

[State specs are in the token module above](/m3/pages/menus/specs#c811d2fa-469a-4e4e-9d9f-0f535c5c9b4c)

### Measurements

_footer: Baseline menu padding and size measurements_
_altText: Diagram of a baseline menu’s padding, text alignment, height, and width._

Attribute
 | Value
 |
Container width
 | 112dp min, 280dp max |
Corner radius
 | 4dp |
Vertical label text alignment
 | Center-aligned |
Horizontal label text alignment
 | Start-aligned |
Left/right padding
 | 12dp |
Left/right padding with-icon
 | 12dp |
List item height
 | 48dp |
Padding between elements within a list item
 | 12dp |
Divider top/bottom padding
 | 8dp |
Divider height
 | 1dp |
Divider width
 | Dynamic |
Leading/trailing icon size
 | 24dp |

### Configurations

A baseline menu appears when a person interacts with a button, action, or other control. 

A few examples:

- Button
- Text field
- Icon button
- Selected text

_altText: Examples of 4 baseline menu inputs._

<!-- section: Guidelines -->

_footer: A menu in the **vibrant** color style is more expressive, and one with **standard** colors is more utilitarian_
_altText: 2 vertical menus, 1 with vibrant colors, 1 with standard colors and grouped items._

## Usage

Use a menu to show a temporary set of actions. To show actions on screen at all times, use a toolbar instead. 

A menu takes up less space than a set of radio buttons or chips. 

### Color options

Menus have two color mappings:

-
Standard: Surface-based, lower visual emphasis

-
Vibrant: Tertiary-based, higher visual emphasis

Vibrant menus are more prominent, and should be used sparingly.

_footer: On web, menus can open submenus_
_altText: Menu shows item “Line spacing” opening a submenu. In the second menu, “Custom 1.2” is selected with vibrant color._

### Opening menus

Menus temporarily appear in front of all other permanent UI elements.

A menu should open when a person:

-
Selects an element, such as an icon, button, or text field

-
Performs a specific action to trigger the menu, like right-click or press-and-hold

Use menus in situations that need extra actions, like: 

-
Overflow menus

-
Text field dropdown menus

-
Select menus

-
Context menus

_footer: Menus appear in front of all other UI elements_
_altText: A grouped menu with Undo, Redo, Cut, Copy, and Paste options appear over highlighted text in an ebook._

### Menu groups

Vertical menu items can be grouped by adding a divider or small gap. Use groups to bundle similar actions together.  

[Gaps and dividers guidelines](/m3/pages/menus/guidelines#d75ac70c-9122-4b4c-bd60-b856bc66c9bc)

_footer: Menu items can be grouped to be more scannable:  - Standard vertical menu - Grouped vertical menu_
_altText: 2 vertical menus: a standard menu with no gap and a grouped menu with 1 gap._

### Context menus

Context menus provide a list of additional actions a person can take on an item. A secondary click, like a right-click on a mouse or a two-finger tap on a trackpad, opens a context menu.

_footer: A context menu appears when right clicking with a mouse or trackpad. It can reveal key actions related to the associated content._
_altText: A context menu pops up from a newspaper link. The menu items are: Open in new window, Save link as, Copy address, and Inspect._

## Anatomy

_footer: - Menu item - Leading icon (optional) - Menu item text - Trailing icon (optional) - Badge (optional) - Trailing text (optional) - Container - Supporting text (optional) - Label text (optional) - Gap (optional) - Divider (optional)_
_altText: Diagram outlining 11 elements of a menu’s anatomy._

### Menu items

Menu items can include label text, leading icons, trailing icons, and keyboard commands. 

When a menu item can only be used under specific conditions, it should appear disabled rather than be removed.

_footer: The **Redo** action is disabled when that action isn’t available_
_altText: Menu shows 1 item that’s  disabled, “Redo”. The text color of the disabled item is lighter than the active items._

### Gaps & dividers (optional)

Gaps and dividers can be used to separate and group menu items.

**Gaps**

Use a gap to visually divide menu items into distinct groups. Gaps are more expressive than dividers and make the relationship between items clear.

- Avoid changing the size of the gap
- Limit the number of gaps in a menu to one or two
- Don’t use gaps in scrollable menus

_footer: Gaps separate menu items using expressive shapes_
_altText: 2 vertical menus with 5 items. A gap separates items into a group of 3 and group of 2._

starNote:Gaps are not currently available on web

**Dividers** 

Dividers create a more subtle separation between items. Use a divider for:

- Scrollable menus
- Text fields with a dropdown menu, where a grouped treatment isn’t appropriate

On web, use a divider to separate menu items.

_footer: Dividers separate menu items in baseline menus and on web_
_altText: A menu on a web interface with items separated by a divider line._

## Flexibility & slots

Menus have custom slots that support more flexible item layouts.

When creating a complicated menu, think of the menu item as a container with a swappable slot.

Slots work best with simple content such as:

- Images
- Progress indicators
- Color swatches

_footer: Slots can appear anywhere in a menu_
_altText: A menu showing an undefined slot that could be used for a different element, such as an image._

**Slot accessibility**

Use caution when adding slots to menus:

- Make sure the menu remains accessible
- Elements must follow the rules and interaction patterns of the menu component
- Keep the same menu item padding
- Targets should be 48x48dp or larger

Don't add buttons, switches, or other direct actions into the menu item. Nested elements should only perform one action. Adding multiple actions can break keyboard navigation and screen reader functionality.

[More on required accessibility guidelines](/m3/pages/menus/accessibility/)

_footer: Reserve the use of slots for use cases that maintain the menu’s accessibility and functionality_
_altText: 1 diagram and 1 menu showing icons in each item’s leading slot._

## Placement

A menu is positioned relative to the window edge. It typically appears below, next to, or in front of the element that generates it.

If a menu is in a position to be cut off, it should automatically reposition to appear to the left, right, or above the element that generates it.

_footer: Menus can appear around or in front of the element that opened them_
_altText: 6 abstract shapes showing how a menu can extend from the edge of the screen._

### Submenus

Submenus should open next to the parent menu item without overlapping it.

Submenus are best used on large screens where there's space. [See adaptive guidance](/m3/pages/menus/guidelines#e588ae16-7a76-4bf9-8532-8d931a13ca35) for alternatives on mobile.

_footer: Position submenus to the side of the parent item_
_altText: A submenu opens to the right of its parent menu item, and doesn’t cover it. A selected submenu item includes a checkmark and vibrant highlight._

starNote:Submenus are not currently available on Jetpack Compose

## Adaptive design

### Compact breakpoints

Consider adapting menus into bottom sheets on small screens. They have more space to display additional items and longer labels.

_footer: A bottom sheet can replace a menu on smaller screens_
_altText: A bottom sheet shows longer labels and improved readability on a compact window._

### Other breakpoints

On medium and expanded windows, menus are most effective as they appear in context with the content. On larger screens, menus can also display more items, and can use submenus to organize complex sets of options.

_footer: On large screens, a menu is often more appropriate than a bottom sheet_
_altText: A menu with vibrant color on a mid-size screen, with the same elements as a bottom sheet._

## Behavior

### Appearing

A menu can appear when a person interacts with an element on the page, like a button, text field, filter chip, or highlighted text.

A menu’s position on screen affects where and how it appears. If opened at the top of the screen, it expands downwards to avoid being cropped.

_footer: Menus at different positions on a screen open in different directions, adapting to the available space_
_altText: A menu activated at the top of the screen expands downwards, then a menu opened at the bottom of the screen expands upward._

_footer: A menu can open from a split button_
_altText: A menu expands downward from the top of the screen, appearing below a split button._

_footer: A menu can appear in context, like next to highlighted text or a selected image_
_altText: A menu expands both above and below a line of selected text, separated by a gap._

_footer: A menu can open from a text field_
_altText: Selecting the “Phone type” text field reveals a menu with multiple options: Business, Mobile (selected), and Home._

_footer: A menu can open from a filter chip_
_altText: A filter chip for “Cycling” in a map UI reveals more menus items: Running, Walking, and Hiking._

**Motion**

Menus use an enter and exit transition. This animation creates a relationship between the menu and the element that generates it.

When a menu expands, the trigger element becomes pressed. When an item is selected, a ripple appears on touch.

_footer: A menu expands when opened, and has a ripple when an item is selected_
_altText: An animation for entering a new contact’s address. The state selection menu expands and the state California is selected._

In dense products, such as on desktop, menus can open instantly to reduce motion.

_footer: Desktop menus can open instantly_
_altText: A menu for changing a font type opens instantly on a desktop UI._

### Filtering

A menu can include a text field to filter options. This pattern is also known as autocomplete. 

As someone types, the list of menu options filters to show relevant results. This helps people quickly find the right option from a long list. 

Menu items ease into their new position as the menu is filtered.

_footer: As a person types in the text field, the menu options filter to match the input_
_altText: An animation showing a text field being typed into. As text is added, the list of menu items below filters down to show only matching options._

### Scrolling

Menus can scroll when all menu items can’t display at once. In this state, menus show a persistent scrollbar.

Don’t use gaps if a menu scrolls; this is currently unsupported.

_footer: When content is scrollable, menus display scrollbars_
_altText: A font menu on a document shows a scrollbar to access font options not currently visible._

### Selecting

When a menu is opened, the corresponding button or icon button should remain the same visually, with the addition of a pressed state.

This should happen even when opening from a keyboard shortcut.

_footer: Tapping the icon triggers a menu. Choosing a menu option doesn’t change the icon generating the menu._
_altText: The overflow icon remains the same, even after the menu is opened._

### Single- and multi-select menus

Menus can allow either single-select or multi-select actions:

- **Single-select** menus can have one item selected at a time. When a new item is selected, the previously selected item is automatically unselected.
- **Multi-select** menus can have many selected items. They stay open until the person dismisses the menu.

[More on selection accessibility requirements](/m3/pages/menus/accessibility#149778c9-eb42-4a56-8a0b-9932181ac2cd)

_footer: Menus can be single- or multi-select_
_altText: 1 menu for dietary options shows a single selection, Vegan. Another menu shows Vegan and Nut-free selections at the same time._

## Focus

When a menu has multiple submenus, focus follows the current hovered or focused submenu. 

**Shape morphing**

As a person moves from one submenu to the next, the corners of the focused submenu become more rounded, while the unfocused submenu becomes less rounded. This adds a dynamic quality to menu interactions.

_footer: On a custom menu, the corner shape changes to indicate focus as the cursor moves across submenus_
_altText: On a submenu next to a main menu, a selected item’s corner shape expands for added emphasis._

## Density

On web only, density levels control the spacing between elements. Increasing density decreases the top and bottom padding. [More on layout density](/m3/pages/understanding-layout/density)

_footer: Density of menus from 0 to -3_
_altText: 4 menus becoming increasingly dense and compressed._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using assistive technology:

- Navigate to, open, and close a menu
- Navigate between and select menu items

## Interaction & style

Menu items need certain cues to clearly show when they're selected: 

- By default, menu items change shape and color when selected
- The default color contrast is 3:1 between selected and unselected menu items
- It's recommended to include another visual cue, like a checkmark

_footer: Use multiple visual cues like color, shape, and icons to show that an item is selected_
_altText: A state dropdown menu with the selected item Alaska highlighted in a vibrant color, with a checkmark icon._

## Flexibility & slots

Use caution when adding slots to menus:

- Make sure the menu remains accessible
- Elements must follow the rules and interaction patterns of the menu component
- Keep the same menu item padding
- Targets should be 48x48dp or larger

Don't add buttons, switches, or other direct actions into the menu item. Nested elements should only perform one action. Adding multiple actions can break keyboard navigation and screen reader functionality.

[More on slots in menus](/m3/pages/menus/guidelines#8a1684bb-99a5-4a73-91a0-068d0b406127)

_footer: Reserve the use of slots for use cases that maintain the menu’s accessibility and functionality_
_altText: 1 diagram and 1 menu showing icons in each item’s leading slot._

## Focus

**Initial focus**

When a menu opens, focus should be placed on the first menu item. This allows people using a keyboard or other assistive technologies to begin navigating the menu immediately.

**Exiting a menu**

People expect to exit a menu by:

- Selecting an option
- Tapping **Escape** or outside of the menu
- Using the system back button

Where focus is placed after closing the menu depends on the app.

_footer: Keyboard navigation on Android and web:  - **Tab** to select a menu item - **Space** or **Enter** to open a menu - **Space** or **Enter** to select a menu item - **Escape** to close a menu_
_altText: 4 common keyboard navigation methods for menus on Android and web._

## Keyboard navigation

**Keys**
 | **Actions**
 |
**Tab** | Focus lands on menu |

**Space**or**Enter**
 |
For closed menus: Opens menu or submenu

For open menus: Selects a menu item
 |
**Up** and **Down** arrows |
For closed menus: Opens menu 

For open menus: Moves focus to the next item
 |
**Left** and **Right** arrows | Opens or closes a submenu |
**Letters** | Focus moves to the next menu item starting with letter |
**Escape** | Closes menu |

## Interactability

Disabled menu items can receive focus but aren't selectable.

Dividers and gaps can't receive focus.

_footer: Disabled menu items can receive focus_
_altText: A disabled menu item “Share” is in focus._

_footer: A divider or gap can’t receive focus_
_altText: A divider with focus._

## Labeling elements

Accessibility labels are used with assistive technology devices like screen readers. 

The accessibility label should be the same as the menu item text.

The role is [dependent on platform](/m3/pages/menus/accessibility#9c562e2c-da3a-4212-a2e3-ac91ba450b65).

_footer: The menu item’s accessibility label aligns with the UI text_
_altText: A “Preview” menu item has an accessibility label of ”preview”._

**Element** |
**A11y label**
 |
**Role (Web)**
 | **Role (Android Views)** |
**Role (Jetpack Compose)**
 |
Menu item text | Preview | Menu item | Generic actionable element | Generic actionable element  |

For menu items with text and an icon, the icon’s accessibility label should be marked as **decorative** to avoid redundant verbalizations.

_footer: For menu items with text and an icon, the icon’s accessibility label is **decorative**_
_altText: A menu item icon of an eye next to the word “preview” has a note of “Decorative.”_

---

<!-- Source: m3.material.io · components_progress-indicators · updated 2026-07-29T13:37:52.778Z · CC-BY 4.0 (Google) -->

## Progress indicators



<!-- section: Overview -->

-
Two variants: linear and circular

-
Use the same configuration for all instances of a process (like loading)

-
They capture attention through motion

-
Option to apply a wave to the active track for use cases that would benefit from increased expressiveness

_footer: Linear and circular progress indicators have visual configurations for shape and thickness_
_altText: 8 progress indicators configured to show different thickness and shape._

## Availability & resources

## M3 Expressive update

**Aug 2024**

The progress indicators have configurations for height and wavy shape. Choose the visual style that best fits your product. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

- Track height: Configurable
- Shape: Wavy

_footer: Progress indicators have a new rounded, colorful style, and more configurations to choose from, including a wavy shape and variable track height_
_altText: Progress indicators used when loading a page and for processing a payment._

## Previous updates

**Dec 2023: Non-text contrast (NTC)**

- Anatomy: Added an end stop indicator to improve accessibility
- Contrast: Higher contrast between track and active indicator to enhance the perception of progress
- Motion: New motion behavior
- Shape: Rounded corners

_footer: Progress indicators have a new rounded, colorful style_
_altText: GM3 linear and circular progress indicators_

## Differences from M2

**July 2022: Added to Material 3**

- **Color:** New color mappings and compatibility with dynamic color

_footer: M2: Progress indicators have a boxier, neutral style_
_altText: M2 linear and circular progress indicators._

_footer: M3: Progress indicators are compatible with dynamic color_
_altText: M3 linear and circular progress indicators._

<!-- section: Specs -->

## Variants

_footer: - Linear progress indicator - Circular progress indicator_
_altText: 2 variant of progress indicators._

Variant
 |
M3
 |
M3 Expressive
 |

Linear progress indicator
 |
Available
 |
Available
 |

Circular progress indicator
 |
Available
 |
Available
 |

## Configurations

_footer: - Behavior: Determinate and indeterminate - Thickness: Default (4dp) and variable - Shape: Flat and wavy_
_altText: 4 configurations of the linear determinate progress indicator._

Category
 |
Configuration
 |
M3
 |
M3 Expressive
 |

Behavior
 |
Determinate (default), Indeterminate
 |
Available
 |
Available
 |

Track thickness
 |
Fixed (4dp) 
 |
Available
 |
Available
 |

Configurable
 |
--
 |
Available
 |

Shape
 |
Flat (default)
 |
Available
 |
Available
 |

Wavy
 |
--
 |
Available
 |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [View baseline tokens](/m3/pages/progress-indicators/specs#c6f484b0-2bc6-4d37-bd75-f859a35a3594)

## Anatomy

_footer: - Active indicator - Track - Stop indicator_
_altText: 3 elements of a progress indicator._

## Color

_footer: Progress indicator color roles used for light and dark schemes:  - Primary  - Secondary container_
_altText: 2 color roles of a linear progress indicator in light and dark themes: the active indicator and stop indicator are primary and the track is secondary container._

## Measurements

Wavy indicators use **amplitude** and **wavelength** to determine the shape of the wave. The height is the overall container height.

_footer: **Amplitude** measures from the center of the resting position to the center of the peak_
_altText: Definitions of wave measurements for height and amplitude._

_footer: **Wavelength** measures the distance between two adjacent peaks_
_altText: Definitions of wave measurements for wavelength._

_footer: Size measurements for linear progress indicators. The thicker variants are provided as sample measurement for makers to adjust the default version based on their use cases._
_altText: Linear progress indicator measurements._

_footer: Size measurements for circular progress indicators. The thicker variants are provided as sample measurement for makers to adjust the default version based on their use cases._
_altText: Circular progress indicator measurements._

_footer: The linear progress indicator is inset from the edge of the screen by 4dp_
_altText: 4dp padding on the left and right of the linear progress indicator._

## Baseline tokens

The circular and linear progress indicator had separate token sets. These are no longer recommended.

<!-- section: Guidelines -->

_footer: Progress indicators communicate the status of an ongoing process_
_altText: Primary colored horizontal line fills a contrasting track from left to right and reaches the end when the app is loaded._

## Usage

Use progress indicators to show the status of ongoing processes, such as loading an app, submitting a form, or saving updates.

When multiple items are loading, use a single progress indicator to show progress for the group. Don’t add progress indicators to every activity.

_footer: Indicate overall progress of a group of items_
_altText: One progress indicator showing the loading progress for a page of podcasts._

_footer: Don’t show the progress of each activity in a group_
_altText: Two progress indicators showing the loading progress of two podcasts._

Choose a loading or progress indicator that corresponds to the expected wait time and kind of process. 

If the wait is very long, consider allowing people to navigate away from the page while the process finishes up.

**Expected wait time**
 | **Recommendation** |
Instant (under 200ms) | No indicator |
Short (between 200ms and 5s) | Loading indicator |
Long (Over 5s) | Progress indicator |

_footer: **Instant (under 200ms):** Display the content immediately_
_altText: Screen without latency without progress indicator._

_footer: **Short (between 200ms and 5s):** Use a loading indicator_
_altText: Screen with slight lag with loading indicator._

_footer: **Long (over 5s):**Use a progress indicator_
_altText: Screen with long lag and progress indicator._

There are two variants of progress indicators:

-
Linear

-
Circular

**Linear** indicators are best when placed on the edge of a container.

**Circular** indicators are best when centered in an element.

A process should be represented by the same variant of progress indicator throughout the product. For example, if refreshing uses a circular indicator in one place, it should use circular indicators everywhere.

_footer: - Linear indicator - Circular indicator_
_altText: 1. A primary colored horizontal line fills a contrasting track from left to right. 2. A circle appears from 0 to 360 degrees._

Progress indicators behave differently based on the time of progress being tracked:

- **Determinate**: Known progress and wait time
- **Indeterminate**: Unknown progress and wait time

When using a **determinate** indicator, the indicator must accurately represent the progress of what it's measuring. 

Use **indeterminate** indicators to show that a process is happening, but the wait time is unknown.

_footer: - Determinate progress indicators fill from 0% to 100% - Indeterminate progress indicators move along a fixed track, growing and shrinking in size_
_altText: Linear and circular progress indicators show both determinate and indeterminate progress._

As more information about a process becomes available, a progress indicator should change from **indeterminate** to **determinate**.

_footer: A linear progress indicator changes from indeterminate to determinate while loading a screen_
_altText: On a track, a contrasting primary-colored horizontal line grows and shrinks, then fills it from left to right as app loads._

## Anatomy

_footer: - Active indicator - Track - Stop indicator_
_altText: 1. The track is a horizontal line. 2. A primary colored line over the contrasting colored track is the progress indicator._

### Active indicator

The active indicator shows the progress that has been made so far. 

In indeterminate processes, it grows and shrinks along the track repeatedly.

_footer: Linear indicators animate from the leading to the trailing edge along the track. Circular indicators animate from the top of the track, clockwise by default._
_altText: A primary colored horizontal line fills a contrasting line from left to right._

The active indicator appears as soon as progress begins. At low percentages where space is limited, this should appear as a dot to help people understand that there’s progress underway.

_footer: When progress first begins, the active indicator appears as a dot_
_altText: A linear and circular progress indicator at 1% progress, where the active indicator has only just appeared._

The active indicator has two shape options: **flat** and **wavy**. Use the shape that best fits the product’s tone.

The wavy shape can make longer processes feel less static and is best used when a more expressive style is appropriate.

When using the wavy shape, the overall height of the component changes. At very small sizes, the wavy shape may not be as visible.

_footer: Wavy linear indicators increase the height of the overall container_
_altText: Examples of flat and wavy active indicator._

### Stop indicator

The stop indicator is a 4dp circle that marks the end of a linear determinate progress indicator to meet Material's accessibility standards.

It's not used for indeterminate or circular progress indicators.

The stop indicator is required if the track has a contrast below 3:1 with its container or the surface behind the container.

_footer: Use a stop indicator when placing the progress indicator inside a container with low contrast_
_altText: A primary colored horizontal  line fills a contrasting line from left to right._

_footer: Only remove the end stop indicator if there's a visual contrast of at least 3:1 with surrounding surfaces_
_altText: An invisible circular track fills with color from 0 to 360 degrees._

## Placement

Place a linear progress indicator along the edge of a container that’s loading. If the container changes shape, place it on the edge that animates. It can also be placed in the middle of a container.

Use a single progress indicator at the top of a page to show progress of the whole group. Don’t add one for every element unless they’re activated independently.

_footer: When at the top of a screen, a progress indicator shows that all of the page content is loading_
_altText: Progress indicator at top of screen, indicating page content is loading._

_footer: When attached to a card, a progress indicator shows that just the card content is loading_
_altText: Progress indicator on a card, indicating that the card's content is loading._

_footer: A progress indicator on the expanding edge of a card shows that the edge may expand to show the loaded content_
_altText: Linear indicator shows the loading progress of a selected news article in a list._

Circular progress indicators should be centered directly on the container or page that's loading, such as a button or card.

When loading more items on a page, place the circular progress indicator in the empty space where the new content will appear, not overlapping existing content.

However, if the content does not take long to load, consider using a loading indicator instead.

_footer: A circular progress indicator can show that the page is loading_
_altText: As content loads, the screen is blank except for a circular progress indicator._

_footer: A circular progress indicator can show where new items will appear on a page. A loading indicator also works well in this space._
_altText: As container content loads, the container is blank except for a circular progress indicator._

### Progress indicators in buttons

A circular indicator can be placed in a button to show that the button’s action is currently in progress.

In very small buttons, use the flat shape since the wavy shape is not as visible at that size.

To ensure a minimum 3:1 contrast ratio, change the active indicator color to be the same color as the button’s icon or label text, and remove the track.

_footer: Use circular indicators for short, indeterminate activities under 5 seconds_
_altText: Determinate circular indicator active for 2 seconds after download button is selected, reflecting download progress._

_footer: Avoid applying progress indicators to every button in a list_
_altText: Shows idea of indeterminate circular indicators active on multiple buttons as  cluttered and confusing._

## Responsive layout

### Right-to-left languages

Linear progress indicators should be mirrored horizontally for products using right-to-left (RTL) languages. 

Circular progress indicators don’t need to be mirrored.

_footer: Linear progress indicators can flow from right to left in right-to-left (RTL) languages_
_altText: Mirrored right-to-left progress indicator._

### Large screens

Circular progress indicators have flexible sizes. They can range from 24dp to 240dp, depending on the placement and the breakpoint. Avoid exceeding the minimum and maximum sizes.

Reserve very large progress indicators for large and extra-large windows, such as desktop.

_footer: The waveform should scale with the size so the proportions look the same across sizes_
_altText: Circular progress indicators can range in size from 24dps to 240dps._

Linear progress indicators dynamically adjust to fit the width of the window or element they’re placed within, such as a card. They shouldn’t be used in any elements smaller than 40dp.

The padding on each end should be 4dp minimum, but can be modified.

_footer: The linear progress indicator should always span the width of the UI element it’s placed within_
_altText: Linear progress indicators can dynamically adjust to any width._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following using the assistive technology:

- Navigate to the progress indicator
- Understand what progress the indicator is communicating

## Interaction & style

The active indicator, which displays progress, provides visual contrast of at least 3:1 against most background colors.

_footer: The progress indicator and stop indicator provide visual contrast of at least 3:1 against most background colors_
_altText: Dark line of progress indicator stands out against the lighter colored track._

When integrated into another component, such as a button, make sure that the active indicator provides visual contrast of at least 3:1 against the other component. 

For the active indicator, use the same color as the label text or icon. The track should be removed.

_footer: Ensure the indicator’s color provides at least 3:1 contrast against the surface it's on_
_altText: Circular indicator on button passes 3 to 1 contrast test._

_footer: Avoid using a color below 3:1 contrast_
_altText: Circular indicator on button fails 3 to 1 contrast test._

For linear progress indicators, the stop indicator is required if the track has a contrast below 3:1 with its container or the surface behind the container.

Essentially, the end of the track must be easy to identify.

_footer: Only remove the stop indicator when the linear progress indicator has at least a 3:1 color contrast with surrounding containers and surfaces_
_altText: Bright container holding the progress bar is on a dark surface, passing the 3:1 color contrast._

_footer: Avoid removing the stop indicator if any adjacent containers or surfaces are below the 3:1 color contrast_
_altText: Bright container holding progress indicator is on a bright surface, failing the 3:1 color contrast._

## Labeling elements

Since the progress indicator is a visual cue, it needs an accessibility label to describe the kind and amount of progress made.

Use the **progress bar**accessibility role, and write an accessibility label that describes the purpose of the progress indicator. The label should include the process, such as "loading,” and the affected content, such as a page, article, or episode. For example: "Loading news article" or "Refreshing page."

_footer: Progress indicator labels should explain which items are loading_
_altText: Determinate linear progress indicator has an accessibility label of “loading news article” and role of “progressbar”._

_footer: A label on an intedeterminate progress indicator on a screen which is loading a set of podcast episodes_
_altText: Indeterminate linear progress indicator has an accessibility label of “loading my episodes” and role of “progressbar.”_

---

<!-- Source: m3.material.io · components_loading-indicator · updated 2026-07-29T13:35:08.589Z · CC-BY 4.0 (Google) -->

## Loading indicator



<!-- section: Overview -->

-
Recommended as a replacement for indeterminate circular progress indicators

-
Always reflect an ongoing process and are never simply decorative

-
Used for pull-to-refresh interactions

-
Not used for processes that transition from indeterminate to determinate  

-
Capture attention through motion

_footer: - Loading indicator - Contained loading indicator_
_altText: A looping sequence of morphs between 7 different shapes in a darker color, sitting on a circular background container in lighter color._

## Availability & resources

## M3 Expressive update

May 2025

The loading indicator is designed to show progress that loads in under five seconds. It should replace most uses of the indeterminate circular progress indicator. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

New component added to catalog.

Loading indicators:

- Are used in pull-to-refresh functionality
- Can be contained or uncontained
- Use shape and motion to capture attention
- Can scale in size

_footer: Loading indicators are used in the pull-to-refresh behavior_
_altText: Loading indicator in news app with pull-to-refresh._

<!-- section: Specs -->

## Variants

_footer: - Loading indicator_
_altText: 2 elements of a loading indicator._

Variant

 |
M3

 |
M3 Expressive

 |

Loading indicator

 |
--

 |
Available

 |

## Configurations

_footer: - Default - Contained_
_altText: 2 configurations of loading indicators._

Category

 |
Configuration

 |
M3

 |
M3 Expressive

 |

Containment

 |
Default

 |
--

 |
Available

 |

Contained

 |
--

 |
Available

 |

## Tokens & specs

Loading indicators have a single token set.

## Anatomy

_footer: - Active indicator - Container_
_altText: 2 elements of a loading indicator._

## Color

### Default

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value.

_footer: Loading indicator color roles used for light and dark schemes:  - Primary_
_altText: 2 color roles of a loading progress indicator in light and dark themes.: the active indicator is primary and the container is secondary container._

### Contained

_footer: Contained loading indicator color roles used for light and dark schemes:  - On primary container - Primary container_
_altText: 2 color roles of a loading progress indicator in light and dark themes. The active indicator is primary and the container is secondary container._

## Measurements

_footer: To ensure sufficient margins, the size is 48dp while the shape container is 38dp_
_altText: Loading progress indicator measurements._

<!-- section: Guidelines -->

_footer: Loading indicators are best for indicating a short, indeterminate wait time_
_altText: Loading indicator on media player._

## Usage

Loading indicators use animation to grab attention, mitigate perceived latency, and indicate that an activity is in progress.

They should be used when progress isn’t detectable, or when it’s not necessary to indicate how long an activity will take.

While similar in function to circular progress indicators, loading indicators are a better alternative for short processes between 200ms and 5s.

_footer: Use a loading indicator when a background process is running_
_altText: Loading indicator in loading state with “Getting your device ready...”._

Choose a loading or progress indicator that corresponds to the expected wait time and type of process. 

If the wait is very long, consider allowing users to navigate away from the page while the process finishes up.

Expected wait time
 | Recommendation
 |
Instant (under 200ms) | No indicator |
Short (between 200ms and 5s) | Loading indicator |
Long (Over 5s) | Progress indicator |

_footer: **Instant (under 200ms):** Display the content immediately_
_altText: Content appearing on a screen quickly without a loading indicator._

_footer: **Short (between 200ms and 5s):** Use a loading indicator_
_altText: Content appearing on a screen with a slight lag and a loading indicator._

_footer: **Long (over 5s):** Use a progress indicator_
_altText: Content appearing on a screen with a long lag and a progress indicator._

When a process can transition from indeterminate (unknown progress) to determinate (known remaining progress), transition between the corresponding progress indicators. 

Don’t transition a loading indicator into a progress indicator.

_footer: Transition from an indeterminate progress indicator to a determinate progress indicator_
_altText: A screen transitioning from an indeterminate progress indicator to a determinate progress indicator._

_footer: Avoid transitioning from a loading indicator to a determinate progress indicator_
_altText: A screen transitioning from a loading indicator to a determinate progress indicator._

## Anatomy

_footer: - Active indicator - Container (optional)_
_altText: 2 parts of an active indicator._

### Active indicator

The active indicator is a looping shape morph sequence composed of seven unique Material 3 shapes.

[More about the Material shape library](/m3/pages/shape/overview-principles#579dd4ba-39f3-4e60-bd9b-1d97ed6ef1bf)

_footer: The active indicator morphs shape to capture attention_
_altText: Active indicator with shape morph._

### Container (optional)

When the container is visible, the active indicator should change color from **primary** to **on-primary-container**.

The container should be visible when the loading indicator is placed over other content. This helps it stand out better by giving it a stronger contrast. It’s not needed when the loading indicator is placed directly on a surface.

The container should be used with pull-to-refresh behavior.

_footer: The container is a circle that provides extra contrast from body content_
_altText: Active indicator with container._

## Placement

While loading a page or container, the loading indicator should be centered on the element.

_footer: Center the loading indicator in the middle of the page or container_
_altText: Active indicator with shape morph centered on a screen._

When loading more items on a page with existing content, place the loading indicator in the empty space where the new content will appear. Avoid overlapping existing content.

_footer: Center the loading indicator in the empty space where content will appear_
_altText: Loading indicator with shape morph underneath photos in a photo app._

Loading indicators can be placed within other components, such as buttons, to indicate that the action is ongoing, such as validating a form or checking for updates.

_footer: Loading indicators can be placed in buttons that take a few seconds to take effect_
_altText: Loading indicator in a button._

_footer: Use loading indicators to show progress without taking up much space_
_altText: Loading indicator as the icon in a tab._

## Responsive layout

Loading indicators default to 48dp, but the size is flexible. It should be between 24dp to 240dp, depending on the placement and the breakpoint. Avoid exceeding the minimum and maximum sizes.

The ratio between the container and the active indicator stays the same when resizing the loading indicator. 

Reserve very large progress indicators for large and extra-large windows, like desktop.

_footer: Loading indicators can range in size from 24–240dp_
_altText: Loading indicators can range from 24dps to 240dps._

### Larger windows

As the pane or window size grows, consider scaling the loading indicator as well, so it remains proportional in size to the empty space around it. The loading indicator shouldn’t exceed 240dp.

_footer: The loading indicator’s default size is ideal for mobile and other compact windows. The loading indicator should scale up in larger windows._
_altText: Loading indicator on mobile and tablet screens._

## Behavior

### Pull-to-refresh

The loading indicator is used in [pull-to-refresh](https://developer.android.com/develop/ui/compose/components/pull-to-refresh) on Jetpack Compose only.

Pull-to-refresh is an Android system feature that manually refreshes screen content with an action or gesture. It’s used at the beginning of lists, grid lists, and card collections where the most recent content appears.

It’s best to use pull-to-refresh with dynamic content that can have frequent updates, where people have a high chance of seeing new content after refreshing.

_footer: The loading indicator for pull-to-refresh can appear on top of the content or adjacent to it_
_altText: A loading indicator can appear above content in pull-to-refresh._

### Threshold requirements

To ensure intentional usage of the pull-to-refresh gesture, the loading indicator must pass a threshold before the app will refresh.

_footer: After passing the threshold, completing the gesture initiates a refresh_
_altText: Loading indicator with screen refresh after threshold time has passed._

_footer: Reversing the gesture past the threshold will cancel the refresh action_
_altText: Loading indicator reversed can cancel refresh action._

The loading indicator remains visible until the refresh activity completes and any new content is visible, or someone navigates away from the refreshing content.

_footer: Keep the loading indicator in view until the activity is completed to provide status of the refresh activity_
_altText: A loading indicator at the top of a screen, which appears until content loads._

_footer: Don’t scroll the loading indicator off-screen, as it hides the status of the refresh activity. It could imply that the refresh activity is associated with a specific component, such as a card, instead of the entire screen._
_altText: A loading indicator that scrolls off screen._

<!-- section: Accessibility -->

## Use cases

People should be able to do the following with assistive technology:

- Navigate to the loading indicator
- Understand what progress the indicator is communicating
- Initiate a content refresh without relying on a gesture

## Interaction & style

The active indicator, which displays progress, provides visual contrast of at least 3:1 against most container and surface colors.

The indicator itself must have 3:1 contrast with the background, but the container does not.

_footer: The loading indicator provides visual contrast of at least 3:1 against most background colors_
_altText: Loading indicator with 3:1 color contrast._

When integrated into another component, such as a button, make sure that the active indicator provides a visual contrast of at least 3:1 against the other component.

_footer: Ensure at least 3:1 contrast between the indicator and the surface it's on_
_altText: Loading indicator with correct color contrast._

_footer: Avoid using when the contrast is under 3:1_
_altText: Loading indicator with incorrect color contrast._

Pull-to-refresh interactions can’t be accessible by just swiping. Provide an alternate way to refresh the content with a single pointer, such as placing a refresh button in a menu or directly alongside the content.

_footer: The refresh action can be in an app bar_
_altText: Refreshing content initiated by an app bar action._

## Labeling elements

Since the loading indicator is a visual cue, it needs an accessibility label to assist people who can't rely on visuals.

It should use the **progress bar** accessibility role. Write a label describing the purpose of the loading indicator, such as **loading news article** or **refreshing page**.

_footer: Loading indicator labels should explain which items are loading_
_altText: Loading indicator accessibility label and role._
