module flow::splay_tree {
    use std::vector;

    const NULL_PTR: u64 = 0xffffffffffffffff;

    // TODO error codes
    const ENO_MESSAGE: u64 = 0;

    struct Node<V: drop> has store, drop {
        key: u64,
        value: V,
        left: u64,
        right: u64
    }

    struct SplayTree<V: drop> has store, drop {
        root: u64,
        nodes: vector<Node<V>>,
    }

    public fun init_tree<V: drop>(): SplayTree<V> {
        SplayTree {
            root: NULL_PTR,
            nodes: vector::empty<Node<V>>(),
        }
    }

    #[test]
    fun test_init_tree() {
        let tree = init_tree<u64>();

        assert!(tree.root == NULL_PTR, ENO_MESSAGE);
        assert!(vector::length(&tree.nodes) == 0, ENO_MESSAGE);
    }

    public fun init_node<V: drop>(key: u64, value: V): Node<V> {
        Node {
            key,
            value,
            left: NULL_PTR,
            right: NULL_PTR
        }
    }

    #[test]
    fun test_init_node() {
        let node = init_node<u64>(0, 0);

        assert!(node.key == 0, ENO_MESSAGE);
        assert!(node.value == 0, ENO_MESSAGE);
        assert!(node.left == NULL_PTR, ENO_MESSAGE);
        assert!(node.right == NULL_PTR, ENO_MESSAGE);
    }

    fun get_left<V: drop>(tree: &SplayTree<V>, idx: u64): u64 {
        vector::borrow(&tree.nodes, idx).left
    }

    fun get_right<V: drop>(tree: &SplayTree<V>, idx: u64): u64 {
        vector::borrow(&tree.nodes, idx).right
    }

    fun set_left<V: drop>(tree: &mut SplayTree<V>, idx: u64, update_to: u64) {
        vector::borrow_mut(&mut tree.nodes, idx).left = update_to;
    }

    fun set_right<V: drop>(tree: &mut SplayTree<V>, idx: u64, update_to: u64) {
        vector::borrow_mut(&mut tree.nodes, idx).right = update_to;
    }

    fun insert_child<V: drop>(tree: &mut SplayTree<V>, parent_idx: u64, node: Node<V>) {
        let parent_node = vector::borrow(&tree.nodes, parent_idx);
        let node_count = vector::length(&tree.nodes);

        if (node.key < parent_node.key) {
            if (parent_node.left == NULL_PTR) {
                vector::push_back(&mut tree.nodes, node);
                let parent_node = vector::borrow_mut(&mut tree.nodes, parent_idx);
                parent_node.left = node_count;
            } else {
                insert_child(tree, parent_node.left, node);
            }
        } else if (node.key > parent_node.key) {
            if (parent_node.right == NULL_PTR) {
                vector::push_back(&mut tree.nodes, node);
                let parent_node = vector::borrow_mut(&mut tree.nodes, parent_idx);
                parent_node.right = node_count;
            } else {
                insert_child(tree, parent_node.right, node);
            }
        }
    }

    public fun insert<V: drop>(tree: &mut SplayTree<V>, node: Node<V>) {
        if (tree.root == NULL_PTR) {
            vector::push_back(&mut tree.nodes, node);
            tree.root = 0;
        } else {
            let parent_idx = tree.root;
            insert_child(tree, parent_idx, node);
        }
    }

    fun rotate_left<V: drop>(tree: &mut SplayTree<V>, parent_idx: u64, child_idx: u64) {
        let child_left = get_left(tree, child_idx);
        set_right(tree, parent_idx, child_left);
        set_left(tree, child_idx, parent_idx);
    }

    fun rotate_right<V: drop>(tree: &mut SplayTree<V>, parent_idx: u64, child_idx: u64) {
        let child_right = get_right(tree, child_idx);
        set_left(tree, parent_idx, child_right);
        set_right(tree, child_idx, parent_idx);
    }

    #[test]
    fun test_add_node() {
        let tree = init_tree<u64>();
        let node = init_node<u64>(0, 0);

        assert!(tree.root == NULL_PTR, ENO_MESSAGE);
        assert!(vector::length(&tree.nodes) == 0, ENO_MESSAGE);

        insert(&mut tree, node);

        assert!(tree.root == 0, ENO_MESSAGE);
        assert!(vector::length(&tree.nodes) == 1, ENO_MESSAGE);
    }

    #[test]
    fun test_add_two_nodes() {
        let tree = init_tree<u64>();

        let key0: u64 = 0;
        let key1: u64 = 1;

        let node0 = init_node<u64>(key0, 0);
        let node1 = init_node<u64>(key1, 1);

        insert(&mut tree, node0);
        insert(&mut tree, node1);

        assert!(tree.root == key0, ENO_MESSAGE);
        assert!(vector::length(&tree.nodes) == 2, ENO_MESSAGE);

        assert!(vector::borrow(&tree.nodes, tree.root).key == key0, ENO_MESSAGE);
        assert!(vector::borrow(&tree.nodes, tree.root).left == NULL_PTR, ENO_MESSAGE);
        assert!(vector::borrow(&tree.nodes, tree.root).right == key1, ENO_MESSAGE);
    }
}
