local while_typing = true

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        float_switch_override_focus = 2,
        sensitivity = 0.5,
        touchpad = {
            natural_scroll = false,
            disable_while_typing = while_typing,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

return {
    toggle_while_typing = function()
        while_typing = not while_typing
        hl.config({
            input = {
                touchpad = {
                    disable_while_typing = while_typing,
                },
            },
        })
    end,
}
