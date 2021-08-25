require_relative "app/controllers/api/api_controller"
require_relative "app/controllers/api/v1/attachments_controller"
require_relative "app/controllers/api/v1/hashtag_posts_controller"
require_relative "app/controllers/api/v1/hashtags_controller"
require_relative "app/controllers/api/v1/post_comments_controller"
require_relative "app/controllers/api/v1/posts_controller"
require_relative "app/controllers/api/v1/users_controller"

use AttachmentsController
use HashtagPostsController
use HashtagsController
use PostCommentsController
use PostsController
use UsersController
run APIController
