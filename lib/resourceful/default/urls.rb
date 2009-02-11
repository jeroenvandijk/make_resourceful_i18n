module Resourceful
  module Default
    # This file contains various methods to make URL helpers less painful.
    # They provide methods analogous to the standard foo_url and foo_path helpers.
    # However, they use make_resourceful's knowledge of the structure of the controller
    # to allow you to avoid figuring out which method to call and which parent objects it should be passed.
    module URLs
      # This returns the path for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   object_path    #=> "/hats/12"
      #   hat_path(@hat) #=> "/hats/12"
      #   hat_path(@hat, :status => 1) #=> "/hats/12?status=1"
      # 
      def object_path(*args)
				object, options = extract_params(args)
				object_route(object, 'path', options)
			end
      # Same as object_path, but with the protocol and hostname.
      def object_url (*args)
				object, options = extract_params(args)
				object_route(object, 'url', options)
			end

      # This is the same as object_path,
      # unless a parent exists.
      # Then it returns the nested path for the object.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   nested_object_path             #=> "/person/42/hats/12"
      #   person_hat_path(@person, @hat) #=> "/person/42/hats/12"
      #   person_hat_path(@person, @hat, :status => 1) #=> "/person/42/hats/12?status=1"
      # 
      def nested_object_path(*args)
				object, options = extract_params(args)
				nested_object_route(object, 'path', options)
			end
      # Same as nested_object_path, but with the protocol and hostname.
      def nested_object_url (*args)
				object, options = extract_params(args)
				nested_object_route(object, 'url', options)
			end

      # This returns the path for the edit action for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   edit_object_path                    #=> "/hats/12/edit"
      #   edit_person_hat_path(@person, @hat) #=> "/hats/12/edit"
      #   edit_person_hat_path(@person, @hat, :status => 1) #=> "/hats/12/edit?status=1"
      # 
      def edit_object_path(*args)
				object, options = extract_params(args)
				edit_object_route(object, 'path', options)
			end
      # Same as edit_object_path, but with the protocol and hostname.
      def edit_object_url (*args)
	 			object, options = extract_params(args)
				edit_object_route(object, 'url', options);  
			end

      # This returns the path for the collection of the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   objects_path              #=> "/people/42/hats"
      #   person_hats_path(@person) #=> "/people/42/hats"
			#   person_hats_path(@person, :status => 1) #=> "/people/42/hats?status=1"
      # 
      def objects_path(*args)
				object, options = extract_params(args)
				objects_route('path', options)
			end
      # Same as objects_path, but with the protocol and hostname.
      def objects_url(*args) 
				object, options = extract_params(args)
				objects_route('url', options)
			end

      # This returns the path for the new action for the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   new_object_path              #=> "/people/42/hats/new"
      #   new_person_hat_path(@person) #=> "/people/42/hats/new"
			#   new_person_hat_path(@person, :status => 1)) #=> "/people/42/hats/new?status=1"
      # 
      def new_object_path(*args)
				object, options = extract_params(args)
				new_object_route('path', options)
			end
      # Same as new_object_path, but with the protocol and hostname.
      def new_object_url(*args) 
				object, options = extract_params(args)
				new_object_route('url', options)
			end

      # This returns the path for the parent object.
      # 
      def parent_path(*args)
				object, options = extract_params(args, :object => parent_object)
        instance_route(parent_class_name.underscore, object, 'path', nil, options)
      end
      # Same as parent_path, but with the protocol and hostname.
      def parent_url(*args)
				object, options = extract_params(args, :object => parent_object)
        instance_route(parent_class_name.underscore, object, 'url', nil, options)
      end

      # This prefix is added to the Rails URL helper names
      # before they're called.
      # By default, it's the underscored list of namespaces of the current controller,
      # or nil if there are no namespaces defined.
      # However, it can be overridden if another prefix is needed.
      # Note that if this is overridden,
      # the new method should return a string ending in an underscore.
      #
      # For example, in Admin::Content::PagesController:
      #
      #   url_helper_prefix #=> "admin_content_"
      #
      # Then object_path is the same as <tt>admin_content_page_path(current_object)</tt>.
      def url_helper_prefix
        namespaces.empty? ? nil : "#{namespaces.join('_')}_"
      end

      # This prefix is added to the Rails URL helper names
      # for the make_resourceful collection URL helpers,
      # objects_path and new_object_path.
      # It's only added if url_helper_prefix returns nil.
      # By default, it's the parent name followed by an underscore if a parent is given,
      # and the empty string otherwise.
      #
      # See also url_helper_prefix.
      def collection_url_prefix
        parent? ? "#{parent_class_name.underscore}_" : ''
      end

      private

      def object_route(object, type, options)
        instance_route(current_model_name.underscore, object, type, nil, options)
      end

      def nested_object_route(object, type, options)
        return object_route(object, type, options) unless parent?
        send_with_options("#{url_helper_prefix}#{parent_class_name.underscore}_#{current_model_name.underscore}_#{type}", parent_object, object, options)
      end

      def edit_object_route(object, type, options)
        instance_route(current_model_name.underscore, object, type, "edit", options)
      end

      def objects_route(type, options)
        collection_route(current_model_name.pluralize.underscore, type, nil, options)
      end

      def new_object_route(type, options) 
        collection_route(current_model_name.underscore, type, "new", options)
      end

      def instance_route(name, object, type, action = nil, options = {})
        send_with_options("#{action ? action + '_' : ''}#{url_helper_prefix}#{name}_#{type}", object.id, options)
      end

      def collection_route(name, type, action = nil, options = {})
        send_with_options("#{action ? action + '_' : ''}#{url_helper_prefix || collection_url_prefix}#{name}_#{type}", (parent? ? [parent_object.id] : []), options)
      end

			# Convenience methods to extract options and arguments from the url helpers
			def send_with_options(*args)
				options = args.extract_options!

				send( *(args + (options.empty? ? [] : [options] ) ).flatten )
			end

			def extract_params(args, options = {})
				args_options = args.extract_options!
				# return the arguments [object, options]
				[args.size == 1 ? args.first : (options[:object] || current_object) ] + [args_options]
			end
    end
  end
end
