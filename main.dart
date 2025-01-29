import 'dart:io';
import 'dart:convert';

void main() {
  List<List> expenses = [];
  List<String> categories = [
    "Food and Drinks",
    "Transportation",
    "Education",
    "Housing and Utilities",
    "Entertainment and Social Activities"
  ];

  print("\n==================== MateSpends ====================");
  String? name = loadName();
  if (name == null) {
    print(
        "\nHello there😊! Welcome to MateSpends, track your daily expenses at your fingertips!\n");
    print("Please enter your name:");
    name = stdin.readLineSync();
    saveName(name);
  } else {
    print("\nWelcome back, $name!\n");
    expenses = loadExpenses();
  }
  mainMenu(name, expenses, categories);
}

void mainMenu(String? name, List<List> expenses, List<String> categories) {
  bool hadExpenses = false;
  while (true) {
    print("\n==================== Main Menu ====================");
    if (expenses.isEmpty && !hadExpenses) {
      print(
          "It seems you haven't added any expenses. Let's start with adding your first expense!\n");
      addExpense(name, expenses, categories);
      hadExpenses = expenses.isNotEmpty;
    } else {
      print("Please choose an option:");
      print("1. Add Expense");
      print("2. Edit Expense");
      print("3. Delete Expense");
      print("4. View Expenses");
      print("0. Exit\n");

      stdout.write("Your choice: ");
      String? option = stdin.readLineSync();
      switch (option) {
        case "1":
          addExpense(name, expenses, categories);
          break;
        case "2":
          editExpense(expenses, categories);
          break;
        case "3":
          deleteExpense(expenses);
          break;
        case "4":
          printExpenses(expenses);
          break;
        case "0":
          print("\nThank you for using MateSpends! Goodbye.\n");
          return;
        default:
          print("Invalid option. Please try again.\n");
      }
    }
  }
}

void addExpense(String? name, List<List> expenses, List<String> categories) {
  print("\n================ Add Expense ================");
  for (int i = 0; i < categories.length; i++) {
    print("${i + 1}. ${categories[i]}");
  }
  stdout.write("Choose a category (1-${categories.length}): ");
  String? input = stdin.readLineSync();
  int category = int.parse(input!);

  if (category > 0 && category <= categories.length) {
    print("\nYou've chosen ${categories[category - 1]}.");
    stdout.write("What do you want to do with the money? ");
    String? note = stdin.readLineSync();
    stdout.write("How much money did you spend? ");
    String? amount = stdin.readLineSync();

    expenses.add([categories[category - 1], amount, note]);
    saveExpenses(expenses);
    print("\nExpense added successfully!\n");
    printExpenses(expenses);
  } else {
    print("Invalid category. Please try again.\n");
    addExpense(name, expenses, categories);
  }
}

void editExpense(List<List> expenses, List<String> categories) {
  if (expenses.isEmpty) {
    print("\nThere are no expenses to edit.\n");
    return;
  }

  print("\n================ Edit Expense ================");
  printExpenses(expenses);
  stdout.write("Select the expense number to edit: ");
  String? input = stdin.readLineSync();
  int index = int.parse(input!) - 1;

  if (index >= 0 && index < expenses.length) {
    print("\nEditing expense #${input}: ${expenses[index][2]}");
    print("1. Edit Category");
    print("2. Edit Amount");
    print("3. Edit Note");
    print("4. Cancel\n");

    stdout.write("Your choice: ");
    String? choice = stdin.readLineSync();
    switch (choice) {
      case "1":
        for (int i = 0; i < categories.length; i++) {
          print("${i + 1}. ${categories[i]}");
        }
        stdout.write("Enter new category: ");
        String? categoryChoice = stdin.readLineSync();
        int newCategory = int.parse(categoryChoice!) - 1;
        expenses[index][0] = categories[newCategory];
        break;
      case "2":
        stdout.write("Enter new amount: ");
        expenses[index][1] = stdin.readLineSync();
        break;
      case "3":
        stdout.write("Enter new note: ");
        expenses[index][2] = stdin.readLineSync();
        break;
      case "4":
        print("Edit canceled.\n");
        return;
      default:
        print("Invalid choice. Returning to the menu.\n");
        return;
    }
    saveExpenses(expenses);
    print("Expense updated successfully!\n");
    printExpenses(expenses);
  } else {
    print("Invalid selection.\n");
  }
}

void deleteExpense(List<List> expenses) {
  if (expenses.isEmpty) {
    print("\nThere are no expenses to delete.\n");
    return;
  }

  print("\n================ Delete Expense ================");
  printExpenses(expenses);
  stdout.write("Select the expense number to delete: ");
  String? input = stdin.readLineSync();
  int index = int.parse(input!) - 1;

  if (index >= 0 && index < expenses.length) {
    stdout.write("Are you sure you want to delete this expense? (y/n): ");
    String? confirm = stdin.readLineSync();
    if (confirm?.toLowerCase() == 'y') {
      expenses.removeAt(index);
      saveExpenses(expenses);
      print("Expense deleted successfully!\n");
      printExpenses(expenses);
    } else {
      print("Deletion canceled.\n");
    }
  } else {
    print("Invalid selection.\n");
  }
}

void printExpenses(List<List> expenses) {
  print("\n================ Your Expenses ================");
  double totalSpent = 0;
  for (int i = 0; i < expenses.length; i++) {
    print("${i + 1}. ${expenses[i][2]}");
    print("   You spent Rp.${expenses[i][1]}");
    print("   Category: ${expenses[i][0]}\n");
    totalSpent += double.parse(expenses[i][1]);
  }
  print("Total amount spent: Rp.${totalSpent}\n");
}

String? loadName() {
  try {
    File file = File('name.json');
    if (file.existsSync()) {
      String contents = file.readAsStringSync();
      Map<String, dynamic> data = jsonDecode(contents);
      return data['name'];
    }
  } catch (e) {
    print("Error loading name: $e");
  }
  return null;
}

void saveName(String? name) {
  try {
    File file = File('name.json');
    Map<String, dynamic> data = {'name': name};
    file.writeAsStringSync(jsonEncode(data));
  } catch (e) {
    print("Error saving name: $e");
  }
}

List<List> loadExpenses() {
  List<List> expenses = [];
  try {
    File file = File('expenses.json');
    if (file.existsSync()) {
      String contents = file.readAsStringSync();
      List<dynamic> data = jsonDecode(contents);
      for (var expense in data) {
        expenses.add([
          expense['category'],
          expense['amount'],
          expense['note'],
        ]);
      }
    }
  } catch (e) {
    print("Error loading expenses: $e");
  }
  return expenses;
}

void saveExpenses(List<List> expenses) {
  try {
    File file = File('expenses.json');
    List<Map<String, dynamic>> data = [];
    for (var expense in expenses) {
      data.add({
        'category': expense[0],
        'amount': expense[1],
        'note': expense[2],
      });
    }
    file.writeAsStringSync(jsonEncode(data));
  } catch (e) {
    print("Error saving expenses: $e");
  }
}
