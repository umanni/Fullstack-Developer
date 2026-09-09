require "pagy"

# 25 rows keeps the admin list to one screen on a laptop without hiding the
# shape of the data.
Pagy::DEFAULT[:limit] = 25
Pagy::DEFAULT[:size] = 7
