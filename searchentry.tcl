package require tksvg

package provide searchentry 1.0

namespace eval ttksearchentry {
    set dir [file dirname [info script]]
    
    set iconSize [expr {int([tk scaling] / 1.333 * 18)}]
    
    variable images
    set images(SearchNormal) [image create photo -file [file join $dir Search_normal.svg]  -format [list svg -scaletoheight $iconSize]]
    set images(SearchHover)  [image create photo -file [file join $dir Search_hover.svg]   -format [list svg -scaletoheight $iconSize]]
    set images(SearchPress)  [image create photo -file [file join $dir Search_pressed.svg] -format [list svg -scaletoheight $iconSize]]
    
    variable iconWidth [image width $images(SearchNormal)]
    
    # Create style element with dynamic states
    ttk::style element create Entry.image image \
        [list $images(SearchNormal) \
             {active !pressed} $images(SearchHover) \
             {pressed} $images(SearchPress)]

    # Layout with padding for the icon
    ttk::style layout MySearch.entry {
        Entry.field -sticky nswe -children {
            Entry.background -sticky news -children {
                Entry.padding -sticky news -children {
                    Entry.image -side right -sticky e
                    Entry.textarea -side left -expand true
                }
            }
        }
    }
}

proc ttksearchentry::InIcon {W X} {
    variable iconWidth
    
    set EntryWidth [winfo width $W]
    return [expr {$X >= ($EntryWidth - $iconWidth)}]
}

proc ttksearchentry::CheckHover {W X} {
    if [InIcon $W $X] {
        $W state active
        $W configure -cursor arrow
    } else {
        $W state !active
        $W configure -cursor xterm
    }
    
    return
}

proc ttksearchentry::GenerateEventPressed {W} {
    event generate $W <<searchPressed>>
}

proc ttksearchentry::CheckClick {W X Action} {
    if [InIcon $W $X] {
        if {$Action eq "pressed"} {
            $W state pressed
            
            GenerateEventPressed $W
            
            return -code break
        } else {
            $W state !pressed
        }
    }
}

proc ttksearchentry::MakeBind {Path} {
    set Tag [join [list $Path SearchEntry] {}]
    set Tag [string trimleft $Tag .]
    
    bindtags $Path [linsert [bindtags .search ] 1 $Tag]
    
    bind $Tag <Motion>          [namespace code [list CheckHover %W %x]]
    bind $Tag <Leave>           {%W state !active}
    bind $Tag <ButtonPress-1>   [namespace code [list CheckClick %W %x pressed]]
    bind $Tag <ButtonRelease-1> [namespace code [list CheckClick %W %x released]]
    bind $Tag <Return>          [namespace code [list GenerateEventPressed %W]]
    
    return
}

#not in use
proc ttksearchentry::MakeProc {Path} {
    set NewWidgetName [join [list $Path W] _]
    uplevel #0 [list rename $Path $NewWidgetName]
    
    proc ::${Path} {args} {
        set Path [lindex [info level [info level]] 0]
        set Widget [join [list $Path W] _]
        
        lassign $args Command Var Val
        
        if {$Command eq "configure" && $Var eq "-searchcommand"} {
            puts -searchcommand
            return
        }
        return [$Widget {*}$args]
    }
    
    return
}

proc ttk::searchentry {Path args} {
    #not in use
    if [dict exists $args -searchcommand] {
        set SearchCommand [dict get $args -searchcommand]
        dict unset args -searchcommand
    }
    
    ttk::entry $Path -style MySearch.entry {*}$args
    
    ttksearchentry::MakeBind $Path
    # ttksearchentry::MakeProc $Path
    
    return $Path
}