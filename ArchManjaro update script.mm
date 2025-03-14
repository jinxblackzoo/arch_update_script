<map version="freeplane 1.12.1">
<!--To view this file, download free mind mapping software Freeplane from https://www.freeplane.org -->
<node TEXT="Arch/Manjaro update script" LOCALIZED_STYLE_REF="AutomaticLayout.level.root" FOLDED="false" ID="ID_1090958577" CREATED="1409300609620" MODIFIED="1741968889950"><hook NAME="MapStyle" background="#2e3440ff">
    <properties fit_to_viewport="false" show_icon_for_attributes="true" show_note_icons="true" edgeColorConfiguration="#808080ff,#ff0000ff,#0000ffff,#00ff00ff,#ff00ffff,#00ffffff,#7c0000ff,#00007cff,#007c00ff,#7c007cff,#007c7cff,#7c7c00ff" show_icons="BESIDE_NODES" associatedTemplateLocation="template:/dark_nord_template.mm" show_tags="UNDER_NODES"/>
    <tags category_separator="::"/>

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node" STYLE="oval" UNIFORM_SHAPE="true" VGAP_QUANTITY="24 pt">
<font SIZE="24"/>
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="bottom_or_right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="default" ID="ID_671184412" ICON_SIZE="12 pt" FORMAT_AS_HYPERLINK="false" COLOR="#484747" BACKGROUND_COLOR="#eceff4" STYLE="bubble" SHAPE_HORIZONTAL_MARGIN="8 pt" SHAPE_VERTICAL_MARGIN="5 pt" BORDER_WIDTH_LIKE_EDGE="false" BORDER_WIDTH="1.9 px" BORDER_COLOR_LIKE_EDGE="true" BORDER_COLOR="#f0f0f0" BORDER_DASH_LIKE_EDGE="true" BORDER_DASH="SOLID">
<arrowlink SHAPE="CUBIC_CURVE" COLOR="#88c0d0" WIDTH="2" TRANSPARENCY="255" DASH="" FONT_SIZE="9" FONT_FAMILY="SansSerif" DESTINATION="ID_671184412" STARTARROW="NONE" ENDARROW="DEFAULT"/>
<font NAME="SansSerif" SIZE="11" BOLD="false" STRIKETHROUGH="false" ITALIC="false"/>
<edge STYLE="bezier" COLOR="#81a1c1" WIDTH="3" DASH="SOLID"/>
<richcontent TYPE="DETAILS" CONTENT-TYPE="plain/auto"/>
<richcontent TYPE="NOTE" CONTENT-TYPE="plain/auto"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details" BORDER_WIDTH="1.9 px">
<edge STYLE="bezier" COLOR="#81a1c1" WIDTH="3"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.tags">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.attributes">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.note" COLOR="#000000" BACKGROUND_COLOR="#ebcb8b">
<icon BUILTIN="clock2"/>
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.floating" COLOR="#484747">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.selection" COLOR="#e5e9f0" BACKGROUND_COLOR="#5e81ac" BORDER_COLOR_LIKE_EDGE="false" BORDER_COLOR="#5e81ac"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="bottom_or_right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="styles.important" ID="ID_779275544" BORDER_COLOR_LIKE_EDGE="false" BORDER_COLOR="#bf616a">
<icon BUILTIN="yes"/>
<arrowlink COLOR="#bf616a" TRANSPARENCY="255" DESTINATION="ID_779275544"/>
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.flower" COLOR="#ffffff" BACKGROUND_COLOR="#255aba" STYLE="oval" TEXT_ALIGN="CENTER" BORDER_WIDTH_LIKE_EDGE="false" BORDER_WIDTH="22 pt" BORDER_COLOR_LIKE_EDGE="false" BORDER_COLOR="#f9d71c" BORDER_DASH_LIKE_EDGE="false" BORDER_DASH="CLOSE_DOTS" MAX_WIDTH="6 cm" MIN_WIDTH="3 cm"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="bottom_or_right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#ffffff" BACKGROUND_COLOR="#484747" STYLE="bubble" SHAPE_HORIZONTAL_MARGIN="10 pt" SHAPE_VERTICAL_MARGIN="10 pt">
<font NAME="Ubuntu" SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#eceff4" BACKGROUND_COLOR="#d08770" STYLE="bubble" SHAPE_HORIZONTAL_MARGIN="8 pt" SHAPE_VERTICAL_MARGIN="5 pt">
<font NAME="Ubuntu" SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#3b4252" BACKGROUND_COLOR="#ebcb8b">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#2e3440" BACKGROUND_COLOR="#a3be8c">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#2e3440" BACKGROUND_COLOR="#b48ead">
<font SIZE="11"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,5" BACKGROUND_COLOR="#81a1c1">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,6" BACKGROUND_COLOR="#88c0d0">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,7" BACKGROUND_COLOR="#8fbcbb">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,8" BACKGROUND_COLOR="#d8dee9">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,9" BACKGROUND_COLOR="#e5e9f0">
<font SIZE="9"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,10" BACKGROUND_COLOR="#eceff4">
<font SIZE="9"/>
</stylenode>
</stylenode>
</stylenode>
</map_styles>
</hook>
<hook NAME="accessories/plugins/AutomaticLayout.properties" VALUE="ALL"/>
<font BOLD="true"/>
<node TEXT="Bedingungen" POSITION="bottom_or_right" ID="ID_872361646" CREATED="1741968890935" MODIFIED="1741968920016">
<node TEXT="Nur eine sudo-PW Eingabe für kompletten Script" ID="ID_1920904998" CREATED="1741969296846" MODIFIED="1741969320952"/>
<node TEXT="Keine Nachfragen oder weiteren Bestätigungen nötig" ID="ID_364675876" CREATED="1741969321647" MODIFIED="1741969337909"/>
<node TEXT="Klare und für Laien verständliche Fehler oder Erfolgsmeldung am Schluss" ID="ID_1252808676" CREATED="1741969338595" MODIFIED="1741969380595"/>
<node TEXT="Protokollierung" ID="ID_848822054" CREATED="1741969381053" MODIFIED="1741969389186"/>
</node>
<node TEXT="Ablauf" POSITION="bottom_or_right" ID="ID_1359963096" CREATED="1741968921368" MODIFIED="1741968925205">
<node TEXT="Abfrage ob neuen Github Akkount abonnieren" ID="ID_1097709824" CREATED="1741968964765" MODIFIED="1741969062917">
<node TEXT="Ja" ID="ID_1272846766" CREATED="1741969012950" MODIFIED="1741969062917" VSHIFT_QUANTITY="-43.5 pt">
<node TEXT="Neuen Github Akkount hinzufügen" ID="ID_212871391" CREATED="1741969029270" MODIFIED="1741969044965">
<node TEXT="Danach weiter bei" ID="ID_1839475246" CREATED="1741969125732" MODIFIED="1741969193989">
<arrowlink DESTINATION="ID_788813575" STARTINCLINATION="9.75 pt;37.5 pt;" ENDINCLINATION="-10.5 pt;-44.25 pt;"/>
</node>
</node>
</node>
<node TEXT="Nein" ID="ID_62833237" CREATED="1741969016414" MODIFIED="1741969065077" VSHIFT_QUANTITY="33 pt">
<node TEXT="Update Start Auswahl:" ID="ID_788813575" CREATED="1741969141605" MODIFIED="1741969697596">
<node TEXT="Vollständiges Update" POSITION="bottom_or_right" ID="ID_1160318792" CREATED="1741968927760" MODIFIED="1741969205886" VSHIFT_QUANTITY="-18 pt">
<node TEXT="yay, snap und flatpak installieren und einrichten, wenn noch nicht installiert" ID="ID_59927581" CREATED="1741969527289" MODIFIED="1741969567815">
<node TEXT="Paketquellen aktualisieren und automatisch installieren" POSITION="bottom_or_right" ID="ID_315489972" CREATED="1741969403917" MODIFIED="1741969425502">
<node TEXT="pacman" ID="ID_1722251546" CREATED="1741969429018" MODIFIED="1741969433427"/>
<node TEXT="yay" ID="ID_1838673366" CREATED="1741969434726" MODIFIED="1741969665722"/>
<node TEXT="flatpak" ID="ID_703704016" CREATED="1741969438289" MODIFIED="1741969670248"/>
<node TEXT="snap" ID="ID_1217582785" CREATED="1741969445641" MODIFIED="1741969673385"/>
<node TEXT="Github" ID="ID_739626738" CREATED="1741969748160" MODIFIED="1741969751537"/>
</node>
<node TEXT="Schlüssel aktualisieren" POSITION="bottom_or_right" ID="ID_681756075" CREATED="1741969583498" MODIFIED="1741969598357"/>
<node TEXT="Mirror aktualisieren" POSITION="bottom_or_right" ID="ID_386638148" CREATED="1741969598736" MODIFIED="1741969607971"/>
<node TEXT="Cache leeren" POSITION="bottom_or_right" ID="ID_1580911182" CREATED="1741969608840" MODIFIED="1741969616009"/>
<node TEXT="Nicht mehr benötigte Abhängigkeiten entfernen" POSITION="bottom_or_right" ID="ID_1359221560" CREATED="1741969616429" MODIFIED="1741969630059"/>
</node>
</node>
<node TEXT="Schnelles Update" POSITION="bottom_or_right" ID="ID_893633698" CREATED="1741968938855" MODIFIED="1741969203205" VSHIFT_QUANTITY="54.75 pt">
<node TEXT="yay, snap und flatpak installieren und einrichten, wenn noch nicht installiert" ID="ID_1409097824" CREATED="1741969527289" MODIFIED="1741969567815">
<node TEXT="Paketquellen aktualisieren und automatisch installieren" POSITION="bottom_or_right" ID="ID_965566344" CREATED="1741969403917" MODIFIED="1741969425502">
<node TEXT="pacman" ID="ID_37061013" CREATED="1741969429018" MODIFIED="1741969433427"/>
<node TEXT="yay" ID="ID_1500287487" CREATED="1741969434726" MODIFIED="1741969654616"/>
<node TEXT="flatpak" ID="ID_147268447" CREATED="1741969438289" MODIFIED="1741969658960"/>
<node TEXT="snap" ID="ID_1011680286" CREATED="1741969445641" MODIFIED="1741969661488"/>
<node TEXT="Github" ID="ID_973936958" CREATED="1741969753525" MODIFIED="1741969756533"/>
</node>
</node>
</node>
</node>
</node>
</node>
</node>
</node>
</map>
