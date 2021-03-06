class TreeBuilderSnapshots < TreeBuilder
  has_kids_for Snapshot, [:x_get_tree_snapshot_kids]

  attr_reader :selected_node

  def initialize(name, type, sandbox, build = true, **params)
    @record = params[:root]
    super(name, type, sandbox, build)
  end

  private

  def override(node, object, _pid, _options)
    if (@selected_node.present? && node[:key] == @selected_node) || object.children.empty?
      node[:highlighted] = true
    end
  end

  def tree_init_options
    {:full_ids => true, :lazy => true}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:onclick => 'miqOnClickSnapshots',)
  end

  def root_options
    {
      :text       => @record.name,
      :tooltip    => @record.name,
      :icon       => 'pficon pficon-virtual-machine',
      :selectable => false
    }
  end

  def x_get_tree_roots(count_only = false, _options = {})
    root_kid = @record.snapshots.present? ? @record.snapshots.find_all { |x| x.parent_id.nil? } : []
    open_node("sn-#{root_kid.first.id}") if root_kid.present?
    count_only_or_objects(count_only, root_kid)
  end

  def parent_id(id)
    Snapshot.find(id).parent_id
  end

  def id(kid_id)
    id = kid_id
    while parent_id(kid_id).present?
      kid_id = parent_id(kid_id)
      id = "#{kid_id}_sn-#{id}"
    end
    "sn-#{id}"
  end

  def x_get_tree_snapshot_kids(parent, count_only)
    kids = parent.children.presence || []
    if kids.present?
      id = id(kids.first.id)
      open_node(id)
    end
    # select last node if no node was selected
    @selected_node = id(parent.id) if @selected_node.nil? && kids.empty?
    count_only_or_objects(count_only, kids)
  end
end
