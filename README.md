# Modern web images
This repo describe, how to convert images into modern formats and configure webserver to return modern
images for visitors, who support them.

## Requirements
Expected, that you use nginx as webserver and Ubuntu as OS.

In case, if you use another OS (for example, CentOS), you will need to find packages for you os and
modify script to use them.

Required packages
- **webp** - to convert images into webp format. To install use command ```sudo apt-get install webp```
- **imagemagick** - to convert images into avif format. To install use command ```sudo apt install imagemagick```

## TL;DR
If you need only converter, then

```
./images-convert.sh ./images/
```

This will create copies in WEBP and AVIF formats for all JPEG/PNG files in ./images/ folder.
As result, you will get follow:

```
images/image1.jpeg
images/image1.jpeg.avif
images/image1.jpeg.webp
images/subfolder1/subfolder2/image2.png
images/subfolder1/subfolder2/image2.png.avif
images/subfolder1/subfolder2/image2.png.webp
```

Next will be described integration into webserver


## 1. Configure NGINX
First of all, we need to check, if visitor support this formats. To use this, add next code to you 
global nginx configuration before "server" block. It will check visitor browser support and set
variables.

```
map $http_accept $webp_suffix {
    default "";
    "~*webp" ".webp";
}
map $http_accept $avif_suffix {
    default "";
    "~*avif" ".avif";
}
```

Next, add next code in you "server" block to override response.

```
location ~* ^(/upload/.+)\.(png|jpe?g)$ {
    set $base $1.$2;
    add_header Vary Accept;
    try_files $base$avif_suffix $base$webp_suffix $uri =404;
}
```

"/upload/" is path where contains you website images. This is relative path from webserver root folder.

Probably you will need to change this path to you own, or add multiple locations.

## 2. Copy script into any folder in you server and set execution permissions
```
cp ./images-converter.sh /var/www/
chmod +x /var/www/images-converter.sh
```

## 3. Schedule script execution in crontab
For example, run script daily at 2 AM for *upload* folder

```
00 02 * * * /var/www/images-converter.sh /var/www/upload/
```

## Manual run
For first time you may want to run script immediately. So, you can run next command to convert images
immediately:
```
./images-converter.sh /var/www/upload/
```

# Script description
You probably don't need it, but if you do - below will be described parts of script.

As argument, script expects path to folder with images,
for example: 

```
./images-converter.sh /var/www/upload/
```

And create 2 copies for each image. One in WEBP format, another - in AVIF. Copies stay near to
original image and has names as original, bit with new extension part:

```
images/image1.jpeg
images/image1.jpeg.avif
images/image1.jpeg.webp
images/subfolder1/subfolder2/image2.png
images/subfolder1/subfolder2/image2.png.avif
images/subfolder1/subfolder2/image2.png.webp
```

## Converting images to WEBP
To do this, script use **webp** package (installation described in start of README).

```shell
# Converting JPEG images into WEBP
find $1 -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" \) \
-exec bash -c '
webp_path="$0.webp";
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
```

### Convert images to AVIF
Same think as WEBP convertation, but we can use same settings for jpeg and png

```shell
# Converting ALL images into AVIF
find $1 -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png"\) \
-exec bash -c '
avif_path="$0.avif";
if [ ! -f "$avif_path" ]; then
  convert -quiet "$0" -quality 90% "$avif_path";
fi;' {} \;
```

# Conclusion
Script is oriented for simple websites without complicated structure, CDN, etc.

Pull requests are welcome
