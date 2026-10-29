SECTION "SpeechTextbox Reconstruction", ROM0

SpeechTextbox::
    hlcoord TEXTBOX_X, TEXTBOX_Y
    ld b, TEXTBOX_INNERH
    ld c, TEXTBOX_INNERW
    jp Textbox
