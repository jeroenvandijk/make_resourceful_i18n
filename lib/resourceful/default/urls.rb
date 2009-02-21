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
      def object_path(*args); object_route('path', *extract_object_plus_options(args)); end
      # Same as object_path, but with the protocol and hostname.
      def object_url (*args); object_route('url', *extract_object_plus_options(args)); end

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
      def nested_object_path(*args); nested_object_route('path', *extract_object_plus_options(args)); end

      # Same as nested_object_path, but with the protocol and hostname.
      def nested_object_url (*args); nested_object_route('url', *extract_object_plus_options(args)); end


      # This returns the path for the edit action for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   edit_object_path                    #=> "/hats/12/edit"
      #   edit_person_hat_path(@person, @hat) #=> "/hats/12/edit"
      # 
      def edit_object_path(*args); edit_object_route('path', *extract_object_plus_options(args)); end

      # Same as edit_object_path, but with the protocol and hostname.
      def edit_object_url (*args); edit_object_route('url', *extract_object_plus_options(args)); end

      # This returns the path for the edit action for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   edit_object_path                    #=> "/hats/12/edit"
      #   edit_person_hat_path(@person, @hat) #=> "/hats/12/edit"
      # TODO
      def edit_nested_object_path(*args); edit_nested_object_route('path', *extract_object_plus_options(args)); end

      # Same as edit_object_path, but with the protocol and hostname.
      def edit_nested_object_url (*args); edit_nested_object_route('url', *extract_object_plus_options(args)); end



      # This returns the path for the collection of the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   objects_path              #=> "/people/42/hats"
      #   person_hats_path(@person) #=> "/people/42/hats"
      # 
      def objects_path(*args); objects_route('path', args.extract_options!); end

      # Same as objects_path, but with the protocol and hostname.
      def objects_url(*args); objects_route('url', args.extract_options!); end

      # This returns the path for the collection of the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   nested_objects_path       #=> "/people/42/hats"
      #   person_hats_path(@person) #=> "/people/42/hats"
      # 
      # When there is no parent the following path will be returned:
      #
      #   nested_objects_path       #=> "/hats"
      #   hats_path                 #=> "/hats"
      # 
      def nested_objects_path(*args); nested_objects_route('path', args.extract_options!); end

      # Same as nested_objects_path, but with the protocol and hostname.
      def nested_objects_url(*args); nested_objects_route('url', args.extract_options!); end



      # This returns the path for the new action for the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   new_object_path              #=> "/hats/new"
      #   new_hat_path(@person) #=> "/hats/new"
      # 
      def new_object_path(*args); new_object_route('path', args.extract_options!); end

      # Same as new_object_path, but with the protocol and hostname.
      def new_object_url(*args); new_object_route('url', args.extract_options!); end

      # This returns the path for the new action for the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   new_nested_object_path              #=> "/people/42/hats/new"
      #   new_person_hat_path(@person) #=> "/people/42/hats/new"
      #
      def new_nested_object_path(*args); new_nested_object_route('path', args.extract_options!); end

      # Same as new_object_path, but with the protocol and hostname.
      def new_nested_object_url(*args); new_nested_object_route('url', args.extract_options!); end

      # This returns the path for the parent object.
      def parent_path(*args)
        object, options = extract_object_plus_options(args, :object => parent_object)
        instance_route(parent_class_name.underscore, object, 'path', nil, options)
      end
      # Same as parent_path, but with the protocol and hostname.
      def parent_url(*args)
        object, options = extract_object_plus_options(args, :object => parent_object)
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
      # TODO change documentation
      def url_helper_prefix
        namespaces.empty? ? '' : "#{namespaces.join('_')}_"
      end

      

      # This prefix is added to the Rails URL helper names
      # for the make_resourceful collection URL helpers,
      # objects_path and new_object_path.
      # It's only added if url_helper_prefix returns nil.
      # By default, it's the parent name followed by an underscore if a parent is given,
      # and the empty string otherwise.
      #
      # See also url_helper_prefix.
      # Deprecated
      # def collection_url_prefix
      #   parent? ? "#{parent_class_name.underscore}_" : ''
      # end
      def collection_url_prefix
        parent? ? "#{parent_class_name.underscore}_" : ""
      end

      private

      def object_route(type, object, options);              instance_route(singular_name, object, type, nil, options); end
      def nested_object_route(type, object, options);       nested_instance_route(singular_name, object, type, nil, options); end

      def new_object_route(type, options);                  collection_route(singular_name, type, "new", options); end
      def new_nested_object_route(type, options);           nested_collection_route(singular_name, type, "new", options); end

      def edit_object_route(type, object, options);         instance_route(singular_name, object, type, "edit", options); end
      def edit_nested_object_route(type, object, options);  nested_instance_route(singular_name, object, type, "edit", options); end

      def objects_route(type, options);                     collection_route(plural_name, type, nil, options); end
      def nested_objects_route(type, options);              nested_collection_route(plural_name, type, nil, options); end


      # Abstractions
      def instance_route(name, object, type, action = nil, options = {})
        send_with_options("#{action ? action + '_' : ''}#{helper_prefix}#{name}_#{type}", object, options)
      end

      def collection_route(name, type, action = nil, options = {})
        send_with_options("#{action ? action + '_' : ''}#{helper_prefix}#{name}_#{type}", options)
      end

      # TODO change specs
      def nested_instance_route(name, object, type, action = nil, options = {})
        return instance_route(name, object, type, action, options) unless parent?

        send_with_options("#{action ? action + '_' : ''}#{helper_prefix(:nested => true)}#{name}_#{type}", parent_object, object, options)
      end
      
      # TODO change specs
      def nested_collection_route(name, type, action = nil, options = {})
        return collection_route(name, type, action, options) unless parent?
        send_with_options("#{action ? action + '_' : ''}#{helper_prefix(:nested => true)}#{name}_#{type}", parent_object, options)
      end


      # Convenience methods to extract options and arguments from the url helpers
      def send_with_options(*args)
        options = args.extract_options!

        send( *(args + (options.empty? ? [] : [options] ) ).flatten )
      end

      def extract_object_plus_options(args, options = {})
        args_options = args.extract_options!
        # return the arguments [object, options]
        [args.size == 1 ? args.first : (options[:object] || current_object) ] + [args_options]
      end
      # Helper used in the routes below
      def helper_prefix(options = {})
        url_helper_prefix +
        (options[:nested] ? collection_url_prefix : "")
      end
      
      def singular_name
        current_model_name.underscore
      end
      
      def plural_name
        singular_name.pluralize
      end
    end
  end
end
