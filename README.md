https://github.com/itssidhere/votewiseiq/assets/16454736/b7e12235-b405-4b83-9544-3287db7acd52


# VotewiseIQ

VotewiseIQ is a powerful platform that provides live public sentiment analysis on a variety of topics. It is built using the Flutter framework for the user interface, Flask for the backend, and Firebase for data storage and real-time updates. With VotewiseIQ, you can gain valuable insights into the opinions and attitudes of the general public in real-time.

## Prerequisites

Before starting the project, make sure you have completed the following steps:

1. Generate `firebase_options.dart`: VotewiseIQ uses Firebase for data storage and real-time updates. To set up Firebase in your project, you need to generate the `firebase_options.dart` file. Follow these steps to generate the file:

   - Install FlutterFire CLI:

     ```shell
     flutter pub global activate flutterfire_cli
     ```

   - Run the CLI command and follow the instructions:

     ```shell
     flutterfire configure
     ```

   This command will guide you through the process of connecting your Flutter project with Firebase and generate the `firebase_options.dart` file.

2. Set up the Python API:

   The Python API used in VotewiseIQ needs to be hosted locally or accessible via a tunneling service like ngrok. If you choose to host it locally, make sure you have Python installed on your system and follow these steps:

   - Install the required Python dependencies:

     ```shell
     pip install -r requirements.txt
     ```

   - Start the Flask server:

     ```shell
     python main.py
     ```

   The Flask server will now be running locally and ready to handle API requests from the VotewiseIQ application.

   If you prefer to use ngrok for tunneling, refer to the ngrok documentation for instructions on setting up a secure tunnel to your local Flask server.

## Installation

To run VotewiseIQ locally, follow these steps:

1. Clone the repository:

   ```shell
   git clone https://github.com/your-username/votewiseiq.git
   ```

2. Navigate to the project directory:

   ```shell
   cd votewiseiq
   ```

3. Install the required dependencies:

   ```shell
   flutter pub get
   ```

4. Start the application:

   ```shell
   flutter run
   ```

   This command will launch the VotewiseIQ application on your preferred device or emulator.

## Usage

1. Launch the VotewiseIQ application.
2. Explore the topics or enter a specific topic of interest.
3. Submit your opinions and feedback.
4. Gain real-time sentiment analysis results and visualize the public sentiment on the chosen topic.
5. Utilize the various features such as historical trends, demographic comparisons, and detailed analytics to gain deeper insights.

## Contributing

Contributions are welcome! If you'd like to contribute to VotewiseIQ, please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes and commit them.
4. Push your changes to your forked repository.
5. Submit a pull request.

Please ensure your contributions align with the project's coding style and guidelines.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). Feel free to modify and distribute it as per the terms of the license.

## Acknowledgments

We would like to express our gratitude to the open-source community for their inspiring work and valuable contributions.

## Contact

If you have any questions, suggestions, or feedback, please feel free to reach out to us at sidjha0001@gmail.com. We'd love to hear from you!

Happy sentiment analysis with VotewiseIQ!

