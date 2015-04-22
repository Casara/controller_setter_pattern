# controller_setter_pattern
Pattern for assign instance variables in controllers for use in views, etc.

## Instalation

Add `controller_setter_pattern` to your Gemfile:

```ruby
gem "controller_setter_pattern"
```

## Basic usage

Before setter pattern:

```ruby
class ArticlesController < ApplicationController
  before_action :set_article, except: [:index, :new, :create]

  # GET /articles
  def index
    @articles = Article.all
  end

  # GET /articles/:id
  def show; end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/:id/edit
  def edit; end

  # POST /articles
  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
  
  # PATCH/PUT /articles/:id
  def update
    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end
  
  # DELETE /articles/:id
  def destroy
    @article.destroy
    redirect_to articles_path
  end

  private
    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :text)
    end
end

class CommentsController < ApplicationController
  before_action :set_article
  before_action :set_comment, except: [:index, :new, :create]

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  # DELETE /articles/:article_id/comments/:id
  def destroy
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def set_article
      @article = Article.find(params[:article_id])
    end

    def set_comment
      @comment = @article.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

After setter pattern:

```ruby
class ArticlesController < ApplicationController
  set :article, except: [:index, :new, :create]

  # actions methods ...

  private
    # setter method no more necessary

    def article_params
      params.require(:article).permit(:title, :text)
    end
end

class CommentsController < ApplicationController
  set :article
  set :comment, ancestor: :article, except: [:index, :new, :create]

  # actions methods ...

  private
    def set_article
      @article = Article.find(params[:article_id])
    end

    def set_comment
      @comment = @article.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

In file `app/views/articles/show.html.erb`:

```erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

## Further configuration

**Specify the model name:**

```ruby
set :ebook, model: Book
# @ebook = Book.find(params[:id])
```

**Specify the parameters key to use to fetch the object:**
```ruby
set :ebook, model: Book, finder_params: :isbn
# @ebook = Book.find_by_isbn(params[:isbn])

set :ebook, model: Book, finder_params: [:author, :title]
# @ebook = Book.find_by_author_and_title(params[:author], params[:title])
```

**Specify the scope:**

```ruby
set :user, scope: :active, finder_params: :email
# @user = User.active.find_by_email(params[:email])
```
