class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  def index
    # Busca os 5 pedidos mais recentes que ainda não foram concluídos (fullfiled: false).
    @orders = Order.where(fullfiled: false).order(created_at: :desc).take(5)
    @quick_stats = {
      # Número de vendas (sales): conta quantos pedidos foram feitos hoje.
      sales: Order.where(created_at: Time.now.midnight..Time.now).count,
      # Receita total (revenue): soma o valor total dos pedidos de hoje.
      revenue: Order.where(created_at: Time.now.midnight..Time.now).sum(:total).round(),
      # Média por venda (avg_sale): calcula a média dos valores das vendas de hoje.
      avg_sale: Order.where(created_at: Time.now.midnight..Time.now).average(:total).round(),
      # Média de produtos por venda
      per_sale: OrderProduct.joins(:order).where(

        orders: {
          created_at: Time.now.midnight..Time.now
        }
      ).average(:quantity)
    }

    # Busca os pedidos dos últimos 7 dias.
    # Agrupa esses pedidos por data, gerando um hash onde a chave é a data e o valor é um array de pedidos desse dia.
    @orders_by_day = Order.where("created_at > ?", Time.now - 7.days).order(:created_at)
    @orders_by_day = @orders_by_day.group_by { |order| order.created_at.to_date }

    # Converte @orders_by_day em um array de arrays:
    # A chave do hash (day) é convertida para o nome do dia da semana (Monday, Tuesday etc.).
    # O valor (orders) é somado (orders.sum(&:total)) para obter o total de receita daquele dia.
    @revenue_by_day = @orders_by_day.map { |day, orders| [ day.strftime("%A"), orders.sum(&:total) ] }

    # Garante que o relatório de receita sempre tenha os 7 dias da semana (mesmo se não houver pedidos em alguns dias).
    # Usa um hash data_hash para armazenar a receita de cada dia.
    # Ajusta a ordem dos dias para começar no dia correto e terminar no dia atual.
    if @revenue_by_day.count < 7
      days_of_week = [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ]
      data_hash = @revenue_by_day.to_h
      current_day = Date.today.strftime("%A")
      current_day_index = days_of_week.index(current_day)
      next_day_index = (current_day_index + 1) % days_of_week.length

      ordered_days_with_current_last = days_of_week[next_day_index..-1] + days_of_week[0..next_day_index]
      complete_ordered_array_with_current_last = ordered_days_with_current_last.map {
                |day| [ day, data_hash.fetch(day, 0) ]
            }
      revenue_by_day = complete_ordered_array_with_current_last
    end
  end
end
