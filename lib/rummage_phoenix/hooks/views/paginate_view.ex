defmodule Rummage.Phoenix.PaginateView do
  @moduledoc """
  View Helper for Pagination in Rummage for bootstrap views.

  Usage:

  ```elixir
  defmodule MyApp.ProductView do
    use MyApp.Web, :view
    use Rummage.Phoenix.View, only: [:paginate]
  end
  ```

  OR

  ```elixir
  defmodule MyApp.ProductView do
    use MyApp.Web, :view
    use Rummage.Phoenix.View
  end
  ```

  """

  @doc """
  This macro includes the helpers functions for pagination

  Provides helper functions `pagination_link/3` for creating pagination links in an html.eex
  file of using `Phoenix`.

  Usage:
  Just add the following code in the index template. Make sure that you're passing
  rummage from the controller. Please look at the
  [README](https://github.com/Excipients/rummage_phoenix) for more details

  ```elixir
  pagination_link(@conn, @rummage)
  ```
  """
  defmacro __using__(opts) do
    quote do
      def pagination_link(conn, rummage) do
        pagiante_params = rummage["paginate"]

        per_page =
          String.to_integer(pagiante_params["per_page"] || Rummage.Phoenix.default_per_page())

        page = String.to_integer(pagiante_params["page"] || "1")
        max_page = String.to_integer(pagiante_params["max_page"] || "1")

        if max_page > 1 do
          raw("""
          <nav aria-label="...">
          <ul class="sm:pt-0 xs:pt-4">
            #{conn |> get_raw_links(rummage, per_page, page, max_page) |> Enum.join("\n")}
          </ul>
          </nav>
          """)
        else
          ""
        end
      end

      defp get_raw_links(conn, rummage, per_page, page, max_page) do
        raw_links =
          cond do
            page <= 1 ->
              [raw_disabled_link("&#11013;")]

            true ->
              [
                raw_link(
                  "&#11013;",
                  apply(
                    unquote(opts[:helpers]),
                    String.to_atom("#{unquote(opts[:struct])}_path"),
                    [
                      conn,
                      :index,
                      %{
                        rummage:
                          Map.put(rummage, "paginate", %{
                            "per_page" => per_page,
                            "page" => page - 1
                          })
                      }
                    ]
                  )
                )
              ]
          end

        raw_links =
          raw_links ++
            Enum.map(1..max_page, fn x ->
              case page == x do
                true ->
                  raw_active_link(x)

                _ ->
                  raw_link(
                    x,
                    apply(
                      unquote(opts[:helpers]),
                      String.to_atom("#{unquote(opts[:struct])}_path"),
                      [
                        conn,
                        :index,
                        %{
                          rummage:
                            Map.put(rummage, "paginate", %{"per_page" => per_page, "page" => x})
                        }
                      ]
                    )
                  )
              end
            end)

        raw_links ++
          cond do
            page == max_page ->
              [raw_disabled_link("&#10145;")]

            true ->
              [
                raw_link(
                  "&#10145;",
                  apply(
                    unquote(opts[:helpers]),
                    String.to_atom("#{unquote(opts[:struct])}_path"),
                    [
                      conn,
                      :index,
                      %{
                        rummage:
                          Map.put(rummage, "paginate", %{
                            "per_page" => per_page,
                            "page" => page + 1
                          })
                      }
                    ]
                  )
                )
              ]
          end
      end

      defp raw_disabled_link(name) do
        """
        <li class="inline">
          <a class="relative float-left sm:py-2 sm:px-4 sm:text-base xs:py-1 xs:px-2 xs:text-xs no-underline leading-normal text-tca-gray-7 bg-white border border-tca-gray-5 -ml-px cursor-not-allowed" href="#" tabindex="-1">#{
          name
        }</a>
        </li>
        """
      end

      defp raw_link(name, url) do
        """
        <li class="inline">
          <a class="relative float-left sm:py-2 sm:px-4 sm:text-base xs:py-1 xs:px-2 xs:text-xs no-underline leading-normal text-tca-blue-7 bg-white border border-tca-gray-5 -ml-px hover:z-20 hover:tca-blue-9 hover:bg-tca-gray-4 hover:bg-tca-gray-5" href="#{
          url
        }">#{name}</a>
        </li>
        """
      end

      defp raw_active_link(name) do
        """
        <li class="inline">
          <a class="relative float-left sm:py-2 sm:px-4 sm:text-base xs:py-1 xs:px-2 xs:text-xs leading-normal no-underline text-white bg-tca-blue-7 border border-tca-blue-7 -ml-px z-30" href="#">#{
          name
        } <span class="absolute w-px h-px overflow-hidden">(current)</span></a>
        </li>
        """
      end

      defp search_module do
        unquote(opts[:search]) || Rummage.Ecto.Config.default_search()
      end
    end
  end
end
