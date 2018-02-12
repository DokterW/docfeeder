# **Do**kter's **C**LI **Fee**d Read**er**

A CLI RSS feed reader.

## How to install

Install [doghum](https://github.com/DokterW/doghum)

`doghum install docfeeder`

### Changelog

#### 2018-02-12
* Feed counter wasn't reset properly, so no new articles were displayed. That makes it forget the position, but will fix that later.
* Added a title for which feed you're in. (Thank you for the idea, Cleo!)
* Added a fix for Der Spiegel feeds (similar to FeedBurner fix).

#### 2018-02-07
* Fixed a bug regarding the width if the title is longer than the terminal width.
* Also added a backup of the most recent feed list addition. In case you delete the wrong feed or it bugs out and deletes it all.
* You will also be asked if you really want to delete a feed from your list.

#### 2018-02-07
* Fixed loading issue when added a new feed.
* Added support for feedburner feeds as they like to add an extra link to the source in the xml, but feedburner link must be in the list, not the redirect.

#### 2018-02-06
* Added shortening of article titles if they are longer than the width of the terminal.

#### 2018-02-06
* Fixed the counter when fetching articles. Now it should fetch all articles.
* Also fixed (yet another) counter for when browsing depending on which feed.
* This version should work as intended, or at least just work.

#### 2018-02-05
* Rebuilt the menu so you will get a list of feeds.
* Optimised the code greatly to fit the new menu system.

#### 2018-02-04
* It works!
