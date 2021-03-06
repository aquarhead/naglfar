defmodule Naglfar.Schema do
  use Absinthe.Schema

  alias NaglfarWeb.Resolvers

  def context(ctx) do
    loader = Naglfar.Dataloader.new()

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  query do
    field :types, list_of(:inventory_type) do
      resolve &Resolvers.Inventory.inventory_types/3
    end

    field :type, :inventory_type do
      arg :id, non_null(:id)
      resolve &Resolvers.Inventory.inventory_type/3
    end

    field :category, :inventory_category do
      arg :id, non_null(:id)
      resolve &Resolvers.Inventory.simple_cat/3
    end
  end

  object :inventory_type do
    field :type_id, :id

    field :group, :inventory_group do
      resolve &Resolvers.Inventory.type_group/3
    end

    field :name, :string
    field :description, :string
    field :mass, :float
    field :volume, :float
    field :capacity, :float
    field :portion_size, :integer
    field :race_id, :integer
    field :published, :boolean
    field :market_group_id, :integer
    field :icon_id, :integer
    field :sound_id, :integer
    field :graphic_id, :integer

    field :dogma_attributes, list_of(:dogma_type_attribute) do
      resolve &Resolvers.Dogma.list_type_attributes/3
    end

    field :dogma_effects, list_of(:dogma_type_effect) do
      resolve &Resolvers.Dogma.list_type_effects/3
    end
  end

  object :inventory_group do
    field :group_id, :id
    field :name, :string
    field :icon_id, :integer
    field :use_base_price, :boolean
    field :anchored, :boolean
    field :anchorable, :boolean
    field :fittable_non_singleton, :boolean
    field :published, :boolean

    field :category, :inventory_category do
      resolve fn grp, _, res ->
        Resolvers.Inventory.category(grp, %{id: grp.category_id}, res)
      end
    end

    field :types, list_of(:inventory_type) do
      resolve fn grp, _, res ->
        Resolvers.Inventory.grp_types(grp, %{id: grp.group_id}, res)
      end
    end
  end

  object :inventory_category do
    field :category_id, :id
    field :name, :string
    field :icon_id, :integer
    field :published, :boolean

    field :groups, list_of(:inventory_group) do
      resolve fn cat, _, res ->
        Resolvers.Inventory.cat_groups(cat, %{id: cat.category_id}, res)
      end
    end
  end

  object :dogma_type_attribute do
    field :attribute, :dogma_attribute do
      resolve &Resolvers.Dogma.attribute/3
    end

    field :value_int, :integer
    field :value_float, :float
  end

  object :dogma_attribute do
    field :attribute_id, :id
    field :name, :string
    field :description, :string
    field :icon_id, :integer
    field :default_value, :float
    field :published, :boolean
    field :display_name, :string
    field :stackable, :boolean
    field :high_is_good, :boolean
    field :category_id, :integer

    field :unit, :eve_unit do
      resolve fn attr, _, res ->
        Resolvers.Dogma.unit(attr, %{id: attr.unit_id}, res)
      end
    end
  end

  object :eve_unit do
    field :unit_id, :id
    field :name, :string
    field :display_name, :string
    field :description, :string
  end

  object :dogma_type_effect do
    field :effect, :dogma_effect do
      resolve &Resolvers.Dogma.effect/3
    end

    field :is_default, :boolean
  end

  object :dogma_effect do
    field :effect_id, :id
    field :name, :string
    field :description, :string
    field :effect_category_id, :integer

    field :pre_expression, :dogma_expression do
      resolve fn effect, _, res ->
        Resolvers.Dogma.expression(effect, %{id: effect.pre_expression}, res)
      end
    end

    field :post_expression, :dogma_expression do
      resolve fn effect, _, res ->
        Resolvers.Dogma.expression(effect, %{id: effect.post_expression}, res)
      end
    end

    field :guid, :string
    field :icon_id, :integer
    field :is_offensive, :boolean
    field :is_assistance, :boolean
    field :duration_attribute_id, :integer
    field :tracking_speed_attribute_id, :integer
    field :discharge_attribute_id, :integer
    field :range_attribute_id, :integer
    field :falloff_attribute_id, :integer
    field :disallow_auto_repeat, :boolean
    field :published, :boolean
    field :display_name, :string
    field :is_warp_safe, :boolean
    field :range_chance, :boolean
    field :electronic_chance, :boolean
    field :propulsion_chance, :boolean
    field :distribution, :integer
    field :sfx_name, :string
    field :npc_usage_chance_attribute_id, :integer
    field :npc_activation_chance_attribute_id, :integer
    field :fitting_usage_chance_attribute_id, :integer
    field :modifier_info, :string
  end

  object :dogma_expression do
    field :expression_id, :id

    field :operand, :dogma_operand do
      resolve fn exp, _, res ->
        Resolvers.Dogma.operand(exp, %{id: exp.operand_id}, res)
      end
    end

    field :arg1, :integer
    field :arg2, :integer
    field :expression_value, :string
    field :description, :string
    field :expression_name, :string
    field :expression_type_id, :integer
    field :expression_group_id, :integer
    field :expression_attribute_id, :integer
  end

  object :dogma_operand do
    field :operand_id, :id, resolve: source("operandID")
    field :operand_key, :string, resolve: source("operandKey")
    field :description, :string, resolve: source("description")
    field :format, :string, resolve: source("format")
    field :python_format, :string, resolve: source("pythonFormat")
    field :arg1_category_id, :integer, resolve: source("arg1categoryID")
    field :arg2_category_id, :integer, resolve: source("arg2categoryID")
    field :result_category_id, :integer, resolve: source("resultCategoryID")
  end

  defp source(key) do
    fn map, _, _ -> {:ok, Map.get(map, key)} end
  end
end
