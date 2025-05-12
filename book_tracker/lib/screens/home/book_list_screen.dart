import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_tracker/blocs/book/book_bloc.dart';
import 'package:book_tracker/models/book.dart';
import 'package:book_tracker/utils/constants.dart';
import 'package:book_tracker/components/animated_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookError) {
          return Center(child: Text(state.message));
        }

        if (state is BookLoaded) {
          final books = state.filteredBooks;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64.sp, color: kPrimaryColor),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noBooks,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.bookList),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                    },
                  ),
                  PopupMenuButton<BookGenre>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (genre) {
                      context.read<BookBloc>().add(FilterBooks(genre: genre));
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text(l10n.allGenres),
                      ),
                      ...BookGenre.values.map(
                        (genre) => PopupMenuItem(
                          value: genre,
                          child: Text(genre.name),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(16.r),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = books[index];
                      return FadeSlideAnimation(
                        child: BookCard(book: book),
                      );
                    },
                    childCount: books.length,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        decoration: BoxDecoration(
          color: kTextLightColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: kTextDarkColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: AspectRatio(
                aspectRatio: 0.8,
                child: Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      // ignore: deprecated_member_use
                      color: kPrimaryColor.withOpacity(0.1),
                      child: Icon(Icons.book, size: 48.sp, color: kPrimaryColor),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12.sp,
                      // ignore: deprecated_member_use
                      color: kTextDarkColor.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          book.genre.name,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 16.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
