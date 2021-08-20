require_relative "app/controllers/application_controller"
require_relative "app/controllers/hashtag_posts_controller"
require_relative "app/controllers/hashtags_controller"
require_relative "app/controllers/post_comments_controller"
require_relative "app/controllers/posts_controller"
require_relative "app/controllers/users_controller"

use HashtagPostsController
use HashtagsController
use PostCommentsController
use PostsController
use UsersController
run ApplicationController
