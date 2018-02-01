module ApplicationHelper

  # def sortable(column, title = nil)
  #   title ||= column.titleize
  #   css_class = (column == sort_column) ? "current #{sort_direction}" : nil
  #   direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
  #   link_to title, {sort: column, direction: direction}, {class: css_class}
  # end

  def sortable(column, title = nil)
    title ||= column.titleize

    if column != sort_column
      css_class = nil
    else
      sort_direction == "asc" ? css_class = "fa fa-chevron-up fa-lg" : css_class = "fa fa-chevron-down fa-lg"
    end

    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to "#{title}  <i class='#{css_class}'></i>".html_safe, {sort: column, direction: direction}
  end

end
