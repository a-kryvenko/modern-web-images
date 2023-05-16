#!/bin/bash

# To use this script, server must have packages "webp" and "imagemagick"
# For Ubuntu
# sudo apt-get install webp
# sudo apt-get install imagemagick
# For CentOS
# sudo yum install libwebp-tools
# imagemagick installation for CentOS is more complicated, so find it buy yourself

# Add variable definition to NGINX config
# map $http_accept $webp_suffix {
#     default "";
#     "~*webp" ".webp";
# }
# map $http_accept $avif_suffix {
#     default "";
#     "~*avif" ".avif";
# }

# Add block to NGINX server config
# location ~* ^(/upload/.+)\.(png|jpe?g)$ {
#     add_header Vary Accept;
#     try_files $uri$avif_suffix $uri$webp_suffix $uri =404;
# }

# Add schedule to crontab
# crontab -e
# 00 02 * * * /var/www/web-converter.sh /var/www/upload/

# Converting JPEG images into WEBP
find $1 -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" \) \
-exec bash -c '
webp_path=$0.webp;
if [ ! -f "$webp_path" ]; then
  cwebp -quiet -q 90 "$0" -o "$webp_path";
fi;' {} \;

# Converting PNG images into WEBP
find $1 -type f -and -iname "*.png" \
-exec bash -c '
webp_path=$0.webp;
if [ ! -f "$webp_path" ]; then
  cwebp -quiet -lossless "$0" -o "$webp_path";
fi;' {} \;

# Converting ALL images into AVIF
find $1 -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
-exec bash -c '
avif_path=$0.avif;
if [ ! -f "$avif_path" ]; then
  convert -quiet "$0" -quality 90% "$avif_path";
fi;' {} \;

