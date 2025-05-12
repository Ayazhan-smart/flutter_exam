import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/services/book_service.dart';

// Events
abstract class BookEvent {}

class LoadBooks extends BookEvent {}

class AddBook extends BookEvent {
  final Book book;
  AddBook(this.book);
}

class UpdateBook extends BookEvent {
  final Book book;
  UpdateBook(this.book);
}

class DeleteBook extends BookEvent {
  final String bookId;
  DeleteBook(this.bookId);
}

class FilterBooks extends BookEvent {
  final BookGenre? genre;
  final String? searchQuery;
  final bool? isCompleted;
  FilterBooks({this.genre, this.searchQuery, this.isCompleted});
}

// States
abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<Book> books;
  final BookGenre? selectedGenre;
  final String? searchQuery;
  final bool? isCompleted;

  BookLoaded({
    required this.books,
    this.selectedGenre,
    this.searchQuery,
    this.isCompleted,
  });

  List<Book> get filteredBooks {
    return books.where((book) {
      if (selectedGenre != null && book.genre != selectedGenre) {
        return false;
      }
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        if (!book.title.toLowerCase().contains(query) &&
            !book.author.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (isCompleted != null) {
        if (isCompleted! && book.status != BookStatus.completed) {
          return false;
        }
        if (!isCompleted! && book.status == BookStatus.completed) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  BookLoaded copyWith({
    List<Book>? books,
    BookGenre? selectedGenre,
    String? searchQuery,
    bool? isCompleted,
  }) {
    return BookLoaded(
      books: books ?? this.books,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      searchQuery: searchQuery ?? this.searchQuery,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class BookError extends BookState {
  final String message;
  BookError(this.message);
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookService _bookService;

  BookBloc(this._bookService) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<AddBook>(_onAddBook);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
    on<FilterBooks>(_onFilterBooks);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());
    try {
      final books = await _bookService.getBooks();
      emit(BookLoaded(books: books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onAddBook(AddBook event, Emitter<BookState> emit) async {
    final currentState = state;
    if (currentState is BookLoaded) {
      try {
        await _bookService.addBook(event.book);
        final books = await _bookService.getBooks();
        emit(currentState.copyWith(books: books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateBook(UpdateBook event, Emitter<BookState> emit) async {
    final currentState = state;
    if (currentState is BookLoaded) {
      try {
        await _bookService.updateBook(event.book);
        final books = await _bookService.getBooks();
        emit(currentState.copyWith(books: books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteBook(DeleteBook event, Emitter<BookState> emit) async {
    final currentState = state;
    if (currentState is BookLoaded) {
      try {
        await _bookService.deleteBook(event.bookId);
        final books = await _bookService.getBooks();
        emit(currentState.copyWith(books: books));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    }
  }

  Future<void> _onFilterBooks(FilterBooks event, Emitter<BookState> emit) async {
    final currentState = state;
    if (currentState is BookLoaded) {
      emit(currentState.copyWith(
        selectedGenre: event.genre,
        searchQuery: event.searchQuery,
        isCompleted: event.isCompleted,
      ));
    }
  }
}
