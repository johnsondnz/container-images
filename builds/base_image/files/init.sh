usermod -o -u "$PUID" generic
groupmod -o -g "$PGID" generic

echo "
-------------------------------------
User: generic
User uid:    $(id -u generic)
User gid:    $(id -g generic)
-------------------------------------
"
su generic
