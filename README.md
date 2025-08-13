# searchentry
**Tcl/Tk widget** that extends `ttk::entry` with a built-in search icon, supporting hover and pressed states, and optional click actions. Icon automatically scales based on `tk scaling`. Clicking the icon with mouse button 1 or pressing the Return key generates the virtual event `<<searchPressed>>`.

<img width="158" height="41" alt="image" src="https://github.com/user-attachments/assets/ca220cf5-49ab-4125-bd86-eca70d2207dd" />

---

## Requirements

* Tcl/Tk 8.6 or later
* [`tksvg`](https://github.com/auriocus/tksvg) for SVG image support

---


## Example

```tcl
package require Tk
package require searchentry

# Create entry widget
ttk::searchentry .search
grid .search -row 0 -column 0
bind .search <<searchPressed>> {puts "search pressed on %W"}
```

