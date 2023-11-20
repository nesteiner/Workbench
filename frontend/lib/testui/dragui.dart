import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExampleDragAndDrop(),));

const List<Item> items = [
  Item(
    name: 'Spinach Pizza',
    totalPriceCents: 1299,
    uid: '1',
    imageProvider: NetworkImage('https://flutter'
        '.dev/docs/cookbook/img-files/effects/split-check/Food1.jpg'),
  ),
  Item(
    name: 'Veggie Delight',
    totalPriceCents: 799,
    uid: '2',
    imageProvider: NetworkImage('https://flutter'
        '.dev/docs/cookbook/img-files/effects/split-check/Food2.jpg'),
  ),
  Item(
    name: 'Chicken Parmesan',
    totalPriceCents: 1499,
    uid: '3',
    imageProvider: NetworkImage('https://flutter'
        '.dev/docs/cookbook/img-files/effects/split-check/Food3.jpg'),
  ),
];

class ExampleDragAndDrop extends StatefulWidget {
  const ExampleDragAndDrop({super.key});

  @override
  ExampleDragAndDropState createState() => ExampleDragAndDropState();
}

class ExampleDragAndDropState extends State<ExampleDragAndDrop> with TickerProviderStateMixin {
  final List<Customer> people = [
    Customer(
      name: 'Makayla',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar1.jpg'),
    ),
    Customer(
      name: 'Nathan',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar2.jpg'),
    ),
    Customer(
      name: 'Emilio',
      imageProvider: const NetworkImage('https://flutter'
          '.dev/docs/cookbook/img-files/effects/split-check/Avatar3.jpg'),
    ),
  ];

  final GlobalKey draggableKey = GlobalKey();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(child: buildMenuList()),
              buildPeopleRow()
            ],
          ),
        )
      ],
    );
  }

  Widget buildMenuList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },

      itemBuilder: (context, index) {
        final item = items[index];
        return buildMenuItem(
          item: item
        );
      },
    );
  }

  Widget buildMenuItem({required Item item}) {
    return LongPressDraggable<Item>(
      data: item,
      feedback: DraggingListItem(
        dragKey: draggableKey,
        photoProvider: item.imageProvider,
      ),

      child: MenuListItem(
        name: item.name,
        price: item.formattedTotalItemPrice,
        photoProvider: item.imageProvider,
      ),
    );
  }

  Widget buildPeopleRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        children: people.map((e) => buildPersonWithDropZone(e)).toList()
      ),
    );
  }

  Widget buildPersonWithDropZone(Customer customer) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DragTarget<Item>(
          builder: (context, candidateItems, rejectedItems) {
            return CustomerCart(
              hasItems: customer.items.isNotEmpty,
              highlighted: candidateItems.isNotEmpty,
              customer: customer,
            );
          },

          onAccept: (item) {
            itemDroppedOnCustomerCart(item: item, customer: customer);
          },
        )


      ),
    );
  }

  void itemDroppedOnCustomerCart({
    required Item item,
    required Customer customer
  }) {
    setState(() {
      customer.items.add(item);
    });
  }
}




class Item {
  final int totalPriceCents;
  final String name;
  final String uid;
  final ImageProvider imageProvider;

  const Item({
    required this.totalPriceCents,
    required this.name,
    required this.uid,
    required this.imageProvider
  });

  String get formattedTotalItemPrice => "\$${(totalPriceCents / 100.0).toStringAsFixed(2)}";
}

class Customer {
  final String name;
  final ImageProvider imageProvider;
  final List<Item> items;

  Customer({
    required this.name,
    required this.imageProvider,
    List<Item>? items
  }): items = items ?? [];

  String get formattedTotalItemPrice {
    final totalPriceCents =
    items.fold<int>(0, (prev, item) => prev + item.totalPriceCents);
    return "\$${(totalPriceCents / 100.0).toStringAsFixed(2)}";
  }
}

class DraggingListItem extends StatelessWidget {
  final GlobalKey dragKey;
  final ImageProvider photoProvider;

  const DraggingListItem({
    super.key,
    required this.dragKey,
    required this.photoProvider
  });

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: ClipRRect(
        key: dragKey,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          width: 150,
          child: Opacity(
            opacity: 0.85,
            child: Image(
              image: photoProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuListItem extends StatelessWidget {
  final String name;
  final String price;
  final ImageProvider photoProvider;
  final bool isDepressed;

  const MenuListItem({
    super.key,
    this.name = "",
    this.price = "",
    required this.photoProvider,
    this.isDepressed = false
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    height: isDepressed ? 115 : 120,
                    width: isDepressed ? 115 : 120,
                    child: Image(
                      image: photoProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomerCart extends StatelessWidget {
  final Customer customer;
  final bool highlighted;
  final bool hasItems;

  const CustomerCart({
    super.key,
    required this.customer,
    this.highlighted = false,
    this.hasItems = false
  });

  @override
  Widget build(BuildContext context) {
    final textColor = highlighted ? Colors.white : Colors.blue;

    return Transform.scale(
      scale: highlighted ? 1.075 : 1.0,
      child: Material(
        elevation: highlighted ? 8 : 4,
        borderRadius: BorderRadius.circular(12),
        color: highlighted ? const Color(0xFFF64209) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Image(
                    image: customer.imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 8,),

              Text(customer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: hasItems ? FontWeight.normal : FontWeight.bold),),

              Visibility(
                visible: hasItems,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Column(
                  children: [
                    const SizedBox(height: 4,),
                    Text(customer.formattedTotalItemPrice,),
                    const SizedBox(height: 4,),
                    Text("${customer.items.length} item${customer.items.length != 1 ? 's' : ''}")
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}