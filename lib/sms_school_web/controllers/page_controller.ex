defmodule SmsSchoolWeb.PageController do
  use SmsSchoolWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
