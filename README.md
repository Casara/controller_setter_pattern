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
      render 'new'
    end
  end
  
  # PUT/PATCH /articles/:id
  def update
    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
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
  # GET /articles/:article_id/comments index
  # GET /articles/:article_id/comments
  # GET /articles/:article_id/comments
  # GET /articles/:article_id/comments


  def create
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def set_article
      @article = Article.find(params[:article_id])
    end

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

With setter pattern:

```ruby
class ArticlesController < ApplicationController
  set :article, except: [:index, :new, :create]

  # actions methods ...

  private
    # setter method not more necessary

    def article_params
      params.require(:article).permit(:title, :text)
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
```
